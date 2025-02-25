import {
  devLocalIndexerRef,
  devLocalRetrieverRef,
  devLocalVectorstore,
} from '@genkit-ai/dev-local-vectorstore';
import { startFlowServer } from '@genkit-ai/express';
import { gemini20Flash, googleAI } from "@genkit-ai/googleai";
import { textEmbedding004, vertexAI } from '@genkit-ai/vertexai';
import { readFileSync } from 'fs';
import { genkit, z } from "genkit";
import { Document } from 'genkit/retriever';
import { join } from 'path';

const ai = genkit({
  plugins: [
    googleAI(),
    vertexAI(),
    devLocalVectorstore([
      {
        indexName: 'products',
        embedder: textEmbedding004,
      },
    ]),
  ],
  model: gemini20Flash,
});

// *** Flow #1: Indexing the product catalog ***

// Read and parse the products JSON file
const products = JSON.parse(
  readFileSync(join(__dirname, 'gardening-products.json'), 'utf-8')
) as Array<{
  id: number;
  productName: string;
  description: string;
  manufacturer: string;
  Cost: number;
  image: string;
}>;

const productsIndexer = devLocalIndexerRef('products');
const productsRetriever = devLocalRetrieverRef('products');

// Create a flow to index the product catalog
const indexProducts = ai.defineFlow(
  {
    name: "indexProducts",
    inputSchema: z.void(),
    outputSchema: z.object({
      success: z.boolean(),
      message: z.string(),
    }),
  },
  async () => {
    try {
      console.log('Indexing products from gardening-products.json');

      // Convert products into documents
      const documents = products.map((product) =>
        Document.fromText(product.description, {
          id: product.id,
          productName: product.productName,
          description: product.description,
          manufacturer: product.manufacturer,
          Cost: product.Cost,
        })
      );

      // Add documents to the index
      await ai.index({
        indexer: productsIndexer,
        documents,
      });

      return {
        success: true,
        message: `Successfully indexed ${documents.length} products`,
      };
    } catch (error) {
      return {
        success: false,
        message: `Failed to index products: ${error}`,
      };
    }
  }
);

// *** Flow #2: Q&A between the model and the user ***

const GtInputSchema = ai.defineSchema(
  "GtInputSchema",
  z.object({
    userQuery: z.string(),
    image: z.string().nullable(),
  }),
);

const GtInputWithHistory = z.object({
  input: GtInputSchema,
  history: z.array(z.any()),
});

const GtOutputSchema = ai.defineSchema(
  "GtOutputSchema",
  z.object({
    llmResponse: z.string({
      description: "The query from the model to the user.",
    }),
    optionsForUser: z
      .array(
        z.string({
          description: "Multiple choice options for the user to pick.",
        }),
      ),
    titleForChat: z.string({
      description: "A suggested title for the chat, e.g. 'Rose Care'",
    }).optional(),
  }),
);

const GtOutputWithHistory = z.object({
  output: GtOutputSchema,
  history: z.any(),
});

export const greenThumb = ai.defineFlow(
  {
    name: "greenThumb",
    inputSchema: GtInputWithHistory,
    outputSchema: GtOutputWithHistory,
  },
  async ({ input, history }) => {
    const system = `
You're an expert gardener. The user will ask a question about how to manage the
plants in their garden. Be helpful and ask 3 to 5 clarifying questions,
although only ask one question at a time.

If the user provides an image, use it to help with the user's original query.

Assume that your output is going to be displayed on an interative UI. The user
will interact with you through a set of multiple choice questions. Except when
you're done asking questions, make sure to include options for the user to pick
from.

Each question should be related to the original query from the user. No question
should ask the user about any other topic or to start a new conversation.

When you're done asking questions, reply with a description of a product that
will help the user with their original query and an empty array for the
optionsForUser. This product description should NOT include another question for
the user. The product description should NOT include the name of any specific
product.
`;

    // Only ask for a title if this is the first prompt in the chat.
    const query =
      input.userQuery +
      (history.length == 0 ? `
Please also suggest a short title for this chat that, if possible,
includes the name of the plant in question.
` : "");

    const { output, messages } = await ai.generate({
      ...(history.length == 0 ? { system } : {}),
      prompt: [
        ...(input.image ? [{ media: { url: input.image } }] : []),
        { text: query },
      ],
      messages: history,
      output: { schema: GtOutputSchema },
    });

    const moreQuestions = (output?.optionsForUser?.length ?? 0) > 0;

    // If there are no more questions, search for matching products
    if (!moreQuestions && output?.llmResponse) {
      const docs = await ai.retrieve({
        retriever: productsRetriever,
        query: output.llmResponse,
        options: { k: 3 },
      });

      // Add markdown JSON code block with non-null and unique product data
      const productData = docs.map(doc => doc.metadata)
        .filter(Boolean)
        .filter((product, index, self) =>
          index === self.findIndex(p => p?.id === product?.id)
        );

      console.log('PRODUCT DATA:');
      console.log(JSON.stringify(productData, null, 2));

      // Get a summary from the LLM that includes product recommendations
      const { text: summary } = await ai.generate({
        prompt: `
Based on the user's gardening question and our conversation, here are some
product recommendations:

${JSON.stringify(productData, null, 2)}

Please summarized your final recommendation along with ALL of the products (by
manufacturer, name and price) that are recommended for the user's gardening
question and why that's the case.

Ensure that the summary is provided in markdown format. Don't introduce the
summary with any other text.
`,
        messages, // contains the conversation history
      });

      console.log('SUMMARY:');
      console.log(summary);

      // Set the final response with the summary
      output.llmResponse = summary;
    }

    console.log('OUTPUT:');
    console.log(output);

    return { output: output!, history: messages };
  },
);

startFlowServer({
  flows: [greenThumb, indexProducts],
});

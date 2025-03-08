import {
  devLocalIndexerRef,
  devLocalVectorstore
} from '@genkit-ai/dev-local-vectorstore';
import { startFlowServer } from '@genkit-ai/express';
import { gemini20Flash, googleAI } from "@genkit-ai/googleai";
import { textEmbedding004 } from '@genkit-ai/vertexai';
import { readFileSync } from 'fs';
import { genkit, MessageSchema, z } from "genkit/beta";
import { ToolResponsePartSchema } from 'genkit/model';
import { Document } from 'genkit/retriever';
import { join } from 'path';

const ai = genkit({
  plugins: [
    googleAI(),
    // vertexAI(), // TODO: needed?
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

const loadProducts = () => {
  return JSON.parse(
    readFileSync(join(__dirname, 'gardening-products.json'), 'utf-8')
  ) as Array<{
    id: number;
    productName: string;
    description: string;
    manufacturer: string;
    cost: number;
    image: string;
  }>;
};

const productsIndexer = devLocalIndexerRef('products');
// const productsRetriever = devLocalRetrieverRef('products');

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
      const products = loadProducts();
      const documents = products.map((product) =>
        Document.fromText(product.description, {
          id: product.id,
          productName: product.productName,
          description: product.description,
          manufacturer: product.manufacturer,
          cost: product.cost,
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

const gtInputSchema = z.object({
  prompt: z.string().optional(),
  messages: z.array(MessageSchema).optional(),
  resume: z.object({ respond: z.array(ToolResponsePartSchema) }).optional(),
});

const gtOutputSchema = z.object({
  messages: z.array(MessageSchema),
});

const choiceInterrupt = ai.defineInterrupt(
  {
    name: 'choiceInterrupt',
    description: 'Asks the user a question with a list of choices',
    inputSchema: z.object({
      question: z.string().describe("The model's follow-up question."),
      choices: z.array(z.string()).describe("The list of choices."),
    }),
    outputSchema: z.string().describe("The user's choice."),
  });

const imageInterrupt = ai.defineInterrupt(
  {
    name: 'imageInterrupt',
    description: 'Asks the user to take a picture of their plant',
    inputSchema: z.object({
      question: z.string().describe("The model's follow-up question."),
    }),
    outputSchema: z.string().describe("base64 encoded image."),
  });

const rangeInterrupt = ai.defineInterrupt(
  {
    name: 'rangeInterrupt',
    description: 'Asks the user to choose a number in a range',
    inputSchema: z.object({
      question: z.string().describe("The model's follow-up question."),
      min: z.number().describe("The minimum value of the range."),
      max: z.number().describe("The maximum value of the range."),
    }),
    outputSchema: z.number().describe("A number in the range."),
  });

const gtSystem = `
  You're an expert gardener. The user will ask a question about how to manage
  their plants in their garden. Be helpful and ask 3 to 5 clarifying questions,
  using the choiceInterrupt, imageInterrupt, and rangeInterrupt tools. Do NOT
  ask the user questions without using a tool; they will not be able to respond.
  
  When you're done asking questions, provide a description of a product or
  products that will help the user with their original query. Each product
  description should NOT include another question for the user nor should it
  include the name of any specific product.
`;

export const greenThumb = ai.defineFlow(
  {
    name: "greenThumb",
    inputSchema: gtInputSchema,
    outputSchema: gtOutputSchema,
  },
  async ({ prompt, messages, resume }) => {
    const response = await ai.generate({
      ...(messages && messages.length > 0 ? {} : { system: gtSystem }),
      prompt,
      tools: [choiceInterrupt, imageInterrupt, rangeInterrupt],
      messages,
      resume,
    });

    return {
      messages: response.messages,
    };
  });

// function productsFromDescription(description: string) {
//   // TODO: RAG
//   return [
//     {
//       productName: 'TODO: Product Name',
//       manufacturer: 'TODO: Manufacturer',
//       cost: 19.99,
//       image: 'TODO',
//       reason: description,
//     }];

//   // TODO: RAG
//   //       const docs = await ai.retrieve({
//   //         retriever: productsRetriever,
//   //         query: output.llmResponse,
//   //         options: { k: 3 },
//   //       });

//   //       // Add markdown JSON code block with non-null and unique product data
//   //       const productData = docs.map(doc => doc.metadata)
//   //         .filter(Boolean)
//   //         .filter((product, index, self) =>
//   //           index === self.findIndex(p => p?.id === product?.id)
//   //         );

//   //       console.log('PRODUCT DATA:');
//   //       console.log(JSON.stringify(productData, null, 2));

//   //       // Get a summary from the LLM that includes product recommendations
//   //       const { text: summary } = await ai.generate({
//   //         prompt: `
//   // Based on the user's gardening question and our conversation, here are some
//   // product recommendations:

//   // ${JSON.stringify(productData, null, 2)}

//   // Please summarized your final recommendation along with ALL of the products (by
//   // manufacturer, name and price) that are recommended for the user's gardening
//   // question and why that's the case.

//   // Ensure that the summary is provided in markdown format. Don't introduce the
//   // summary with any other text.
//   // `,
//   //         messages, // contains the conversation history
//   //       });

//   //       console.log('SUMMARY:');
//   //       console.log(summary);

//   //       // Set the final response with the summary
//   //       output.llmResponse = summary;    
// }

startFlowServer({
  flows: [indexProducts, greenThumb],
});

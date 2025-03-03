import {
  devLocalIndexerRef,
  devLocalVectorstore
} from '@genkit-ai/dev-local-vectorstore';
import { startFlowServer } from '@genkit-ai/express';
import { gemini20Flash, googleAI } from "@genkit-ai/googleai";
import { textEmbedding004 } from '@genkit-ai/vertexai';
import assert from 'assert';
import { readFileSync } from 'fs';
import { genkit, z } from "genkit/beta";
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
  type: z.literal("gtInput"),
  query: z.string().describe("The user's plant-related query."),
});

const gtOutputSchema = z.object({
  type: z.literal("gtOutput"),
  recommendation: z.string().describe("How to answer the user's query."),
  products: z.array(z.object({
    productName: z.string().describe("The name of the product."),
    manufacturer: z.string().describe("The manufacturer of the product."),
    cost: z.number().describe("The cost of the product."),
    image: z.string().describe("base64 encoded image of the product."),
    reason: z.string().describe("The reason why this product is recommended."),
  })),
});

const interruptRequestSchema = z.object({
  type: z.literal('interruptRequest'),
  interrupts: z.array(z.any()), // interrupt requests for the client
  messages: z.array(z.any()), // context to continue the flow
});

const interruptResponseSchema = z.object({
  type: z.literal('interruptResponse'),
  interrupts: z.array(z.any()), // context to continue the flow
  results: z.array(z.any()), // interrupt results from the client
  messages: z.array(z.any()), // context to continue the flow
});

const gtChoiceInterrupt = ai.defineInterrupt(
  {
    name: 'gtChoiceInterrupt',
    description: 'Asks the user a question with a list of choices',
    inputSchema: z.object({
      query: z.string().describe("The model's follow-up question."),
      choices: z.array(z.string()).describe("The list of choices."),
    }),
    outputSchema: z.string().describe("The user's choice."),
  });

const gtSystem = `
  You're an expert gardener. The user will ask a question about how to manage the
  plants in their garden. Be helpful and ask 3 to 5 clarifying questions,
  using the 'gtChoiceInterrupt' tool to ask the user questions.
  
  When you're done asking questions, provide a description of a product or
  products that will help the user with their original query. Each product
  description should NOT include another question for the user nor should it
  include the name of any specific product.
`;

export const greenThumb = ai.defineFlow(
  {
    name: "greenThumb",
    inputSchema: z.discriminatedUnion('type', [gtInputSchema, interruptResponseSchema]),
    outputSchema: z.discriminatedUnion('type', [gtOutputSchema, interruptRequestSchema]),
  },
  async (input) => {
    // NOTE: there are several ways to get a tool by name from genkit, but none
    // of them work without compiler errors, so we'll use our own map. sigh.
    const tools: Record<string, any> = {
      'gtChoiceInterrupt': gtChoiceInterrupt,
    };

    let response;
    switch (input.type) {
      case 'gtInput':
        response = await ai.generate({
          system: gtSystem,
          prompt: input.query,
          tools: Object.values(tools),
        });
        break;

      case 'interruptResponse':
        const interruptResponses = [] as any[];
        const interruptCount = input.interrupts.length;
        assert(interruptCount === input.results.length);
        for (let i = 0; i < interruptCount; i++) {
          const interrupt = input.interrupts[i];
          const interruptResult = input.results[i];
          const interruptName = interrupt.toolRequest.name;
          const interruptDefinition = tools[interruptName];

          if (!interruptDefinition) {
            throw new Error(`Interrupt definition not found: ${interruptName}`);
          }

          interruptResponses.push(
            interruptDefinition.respond(interrupt, interruptResult),
          );
        }

        response = await ai.generate({
          tools: Object.values(tools),
          messages: input.messages,
          resume: { respond: interruptResponses },
        });

        break;
    }

    return (response.interrupts.length == 0)
      ? {
        type: 'gtOutput' as const,
        recommendation: response.text,
        products: productsFromDescription(response.text)
      }
      : {
        type: 'interruptRequest' as const,
        messages: response.messages,
        interrupts: response.interrupts,
      };
  },
);

function productsFromDescription(description: string) {
  // TODO: RAG
  return [
    {
      productName: 'TODO: Product Name',
      manufacturer: 'TODO: Manufacturer',
      cost: 19.99,
      image: 'TODO',
      reason: description,
    }];

  // TODO: RAG
  //       const docs = await ai.retrieve({
  //         retriever: productsRetriever,
  //         query: output.llmResponse,
  //         options: { k: 3 },
  //       });

  //       // Add markdown JSON code block with non-null and unique product data
  //       const productData = docs.map(doc => doc.metadata)
  //         .filter(Boolean)
  //         .filter((product, index, self) =>
  //           index === self.findIndex(p => p?.id === product?.id)
  //         );

  //       console.log('PRODUCT DATA:');
  //       console.log(JSON.stringify(productData, null, 2));

  //       // Get a summary from the LLM that includes product recommendations
  //       const { text: summary } = await ai.generate({
  //         prompt: `
  // Based on the user's gardening question and our conversation, here are some
  // product recommendations:

  // ${JSON.stringify(productData, null, 2)}

  // Please summarized your final recommendation along with ALL of the products (by
  // manufacturer, name and price) that are recommended for the user's gardening
  // question and why that's the case.

  // Ensure that the summary is provided in markdown format. Don't introduce the
  // summary with any other text.
  // `,
  //         messages, // contains the conversation history
  //       });

  //       console.log('SUMMARY:');
  //       console.log(summary);

  //       // Set the final response with the summary
  //       output.llmResponse = summary;    
}

startFlowServer({
  flows: [greenThumb, indexProducts],
});

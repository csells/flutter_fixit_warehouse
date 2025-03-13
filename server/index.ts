import {
  devLocalIndexerRef,
  devLocalRetrieverRef,
  devLocalVectorstore
} from '@genkit-ai/dev-local-vectorstore';
import { startFlowServer } from '@genkit-ai/express';
import { gemini20Flash, googleAI } from "@genkit-ai/googleai";
import vertexAI, { textEmbedding004 } from '@genkit-ai/vertexai';
import { readFileSync } from 'fs';
import { genkit, MessageSchema, z } from "genkit/beta";
import { ToolResponsePartSchema } from 'genkit/model';
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
  // turn down the creativity of the model so that it doesn't make up product
  // names or details
  model: gemini20Flash.withConfig({ temperature: 0.3 }),
});

// *** Flow #1: Indexing the product catalog ***

const loadProducts = () => {
  return JSON.parse(
    readFileSync(join(__dirname, 'gardening-products.json'), 'utf-8')
  ) as Array<{
    product: string;
    manufacturer: string;
    description: string;
    cost: number;
    image: string;
    id: number;
  }>;
};

const productsIndexer = devLocalIndexerRef('products');
const productsRetriever = devLocalRetrieverRef('products');

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
          product: product.product,
          manufacturer: product.manufacturer,
          description: product.description,
          cost: product.cost,
          image: product.image,
          id: product.id,
        })
      );

      // Add documents to the index
      await ai.index({ indexer: productsIndexer, documents });

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

const productLookupTool = ai.defineTool(
  {
    name: 'productLookupTool',
    description: 'Find the top product that matches a given description',
    inputSchema: z.object({
      description: z.string().describe('The description of the product')
    }),
    outputSchema: z.object({
      product: z.string().describe('The name of the product'),
      manufacturer: z.string().describe('The manufacturer of the product'),
      cost: z.number().describe('The cost of the product'),
      image: z.string().describe('The image of the product'),
      reason: z.string().describe('The reason for the recommendation'),
    }),
  },
  async (input) => {
    const docs = await ai.retrieve({
      retriever: productsRetriever,
      query: input.description,
      options: { k: 1 },
    });

    const metadata = docs[0].metadata;
    const product = {
      product: metadata?.product || "Unknown",
      manufacturer: metadata?.manufacturer || "Unknown",
      cost: metadata?.cost || 0,
      image: metadata?.image || "",
      reason: `Matched based on: ${input.description}`
    };

    console.log('PRODUCT:');
    console.log(JSON.stringify(product, null, 2));

    return product;
  }
);


const gtSystem = `
You're an expert gardener. The user will ask a question about how to manage
their plants in their garden. Be helpful and ask 3 to 5 clarifying questions,
using the choiceInterrupt, imageInterrupt, and rangeInterrupt tools. Do NOT ask
the user questions without using a tool; they will not be able to respond.

When you're done asking questions, produce the description of a product or
products that will help the user with their original query. YOU MUST pass the
description of each product to the productLookupTool tool to look up the
product details to include in your response.

DO NOT make up any product names or details; ONLY use the product names and
details returned by the productLookupTool tool.

DO NOT use real-world product names; only use the product names returned by the 
productLookupTool tool.

DO NOT make up any images; only use the images returned by the
productLookupTool tool.

The response should be a summary of your final recommendation as well as a list
of products incorporating the product name, manufacturer, cost, and image. The
response should be structured in Markdown format like this:


[put your overall recommendation here; be clear and concise].

To help with that, here are the product(s) that you may want to consider:

# [product 1]
From [manufacturer] for $[cost]

![](product 1 image)

# [product 2]
From [manufacturer] for $[cost]

![](product 2 image)

...
`;

const greenThumb = ai.defineFlow(
  {
    name: "greenThumb",
    inputSchema: gtInputSchema,
    outputSchema: gtOutputSchema,
  },
  async ({ prompt, messages, resume }) => {
    const response = await ai.generate({
      ...(messages && messages.length > 0 ? {} : { system: gtSystem }),
      prompt,
      tools: [choiceInterrupt, imageInterrupt, rangeInterrupt, productLookupTool],
      messages,
      resume,
    });

    return { messages: response.messages };
  });


startFlowServer({
  flows: [indexProducts, greenThumb],
});
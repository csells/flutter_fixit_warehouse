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
    googleAI({
      apiKey: process.env.GOOGLE_GENAI_API_KEY!,
    }),
    vertexAI({
      projectId: process.env.GCP_PROJECT_ID!,
      location: process.env.GCP_LOCATION!,
    }),
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

const choiceInterrupt = ai.defineInterrupt(
  {
    name: 'choice',
    description: 'Asks the user a question with a list of choices',
    inputSchema: z.object({
      question: z.string().describe("The model's follow-up question."),
      choices: z.array(z.string()).describe("The list of choices."),
    }),
    outputSchema: z.string().describe("The user's choice."),
  });

const imageInterrupt = ai.defineInterrupt(
  {
    name: 'image',
    description: 'Asks the user to take a picture of their plant',
    inputSchema: z.object({
      question: z.string().describe("The model's follow-up question."),
    }),
    outputSchema: z.string().describe("base64 encoded image."),
  });

const rangeInterrupt = ai.defineInterrupt(
  {
    name: 'range',
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
    name: 'productLookup',
    description: 'Find the top product that matches a given description',
    inputSchema: z.object({
      description: z.string().describe('The description of the product')
    }),
    outputSchema: z.object({
      product: z.string().describe('The name of the product'),
      manufacturer: z.string().describe('The manufacturer of the product'),
      cost: z.number().describe('The cost of the product'),
      image: z.string().describe('The image of the product'),
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
    };

    console.log('PRODUCT:');
    console.log(JSON.stringify(product, null, 2));

    return product;
  }
);

const gtInputSchema = z.object({
  prompt: z.string().optional(),
  messages: z.array(MessageSchema).optional(),
  resume: z.object({ respond: z.array(ToolResponsePartSchema) }).optional(),
});

const gtOutputSchema = z.object({
  messages: z.array(MessageSchema),
});

const gtSystem = `
You are GreenThumb, an expert gardener assistant integrated into an app that
helps people with their plants. A user will ask you questions about gardening.

You must follow these steps exactly:
1. Ask clarifying questions to the user about their situation.
-	Use the choice, image, and range tools to ask these questions.
- Make sure to use each tool at least once.
-	Do not ask any questions in plain text. All clarifying questions must be asked by calling the appropriate interrupt tool(s).

2. Form a description for each of one or more products that you recommend.
- Use the information you have gathered from the user to form a description for each product.
- The product descriptions MUST NOT contain any product names, manufacturer names, or prices. Those will be looked up in the next step.

3. Use the descriptions to lookup products that match the descriptions.
-	You must call the productLookup tool to fetch product details that match product descriptions you've created.
-	For each product you recommend, you must pass a relevant query or description into the productLookup tool.
-	DO NOT invent product names, DO NOT invent product data, and DO NOT invent images. ONLY use the productLookup tool to find products.

4. Your final response (after you've received the results from the productLookup tool) must follow the Markdown format below:

    [put your overall recommendation here; be clear and concise].

    # [product 1]
    From [manufacturer] for $[cost]

    ![](image)

    # [product 2]
    From [manufacturer] for $[cost]

    ![](image)

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
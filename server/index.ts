import { gemini15Flash, googleAI } from "@genkit-ai/googleai";
import { genkit, z } from "genkit";

const ai = genkit({
  plugins: [googleAI()],
  model: gemini15Flash,
});

const StoreOption = z.object(
  {
    name: z.string(),
    thumbnailUrl: z.string(),
    purchaseUrl: z.string(),
  },
  { description: "Information about a specific product." },
);

const InputSchema = ai.defineSchema(
  "InputSchema",
  z.object({
    userQuery: z.string(),
    image: z.string().optional(),
  }),
);

const InputWithHistory = z.object({
  input: InputSchema,
  history: z.array(z.any()),
});

const OutputSchema = ai.defineSchema(
  "OutputSchema",
  z.object({
    llmQuery: z.string({
      description: "The query from the model to the user.",
    }),
    optionsForUser: z
      .array(
        z.string({
          description: "Multiple choice options for the user to pick.",
        }),
      )
      .optional(),
    storeOptions: z.array(StoreOption).optional(),
  }),
);

const OutputWithHistory = z.object({
  output: OutputSchema,
  history: z.any(),
});

export const greenThumb = ai.defineFlow(
  {
    name: "greenThumb",
    inputSchema: InputWithHistory,
    outputSchema: OutputWithHistory,
  },
  async ({ input, history }) => {


    const system =
      history.length > 0
        ? {}
        : {
          // System is only supported in the first prompt in the history.
          system: `
You're an expert gardener. The user will talk to you to you to figure out what
is wrong with their plants. Be helpful and ask clarifying questions, although
only ask one question at a time.

Assume that your output is going to be displayed on an interative UI. 
The user will interact with you throuh a combination of text and multiple choice
questions.

If the user provides an image, use it to help you answer the user's question.
`,
        };

    const { output, messages } = await ai.generate({
      ...system,
      prompt: [
        ...(input.image ? [{ media: { url: input.image } }] : []),
        { text: input.userQuery },
      ],
      messages: history,
      output: { schema: OutputSchema },
    });

    return { output: output!, history: messages };
  },
);

ai.startFlowServer({
  flows: [greenThumb],
});

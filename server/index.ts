import { gemini15Flash, googleAI } from "@genkit-ai/googleai";
import { genkit, z } from "genkit";

const ai = genkit({
  plugins: [googleAI()],
  model: gemini15Flash,
});

const ProductDescription = z.object(
  {
    description: z.string(),
  },
  { description: "Description of a product that will help the user with their plant." },
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
    storeOptions: z.array(ProductDescription).optional(),
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
You're an expert gardener. The user will ask a question about how to manage the
plants in their garden. Be helpful and ask up to three clarifying questions,
although only ask one question at a time.

If the user provides an image, use it to help with the user's original query.

Assume that your output is going to be displayed on an interative UI. The user
will interact with you through a set of multiple choice questions.

Each question should be related to the original query from the user. No question
should ask the user about any other topic or to start a new conversation.

After the user has answered your follow-up questions, please provide a
description of a product that will help the user with their original query.
This product description should NOT include another question for the user.
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

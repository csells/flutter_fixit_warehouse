import { startFlowServer } from '@genkit-ai/express';
import { gemini20Flash, googleAI } from "@genkit-ai/googleai";
import { genkit, z } from "genkit";

const ai = genkit({
  plugins: [googleAI()],
  model: gemini20Flash,
});

// TODO: two flows:
// one for the follow-up questions,
// one for the product description.
// hopefully that will fix the issue with the product description being
// included in the follow-up questions. and the issue with the questions
// not always being provided with options, e.g.
// “That’s a beautiful rose! To help me recommend the best companion plants,
// what type of rose is it (e.g., hybrid tea, floribunda, climbing)?”

const InputSchema = ai.defineSchema(
  "InputSchema",
  z.object({
    userQuery: z.string(),
    image: z.string().nullable(),
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
    productDescription: z.string({
      description: "A description of a product that will help the user with their original query.",
    }),
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
    const system = `
You're an expert gardener. The user will ask a question about how to manage the
plants in their garden. Be helpful and ask three clarifying questions,
although only ask one question at a time.

If the user provides an image, use it to help with the user's original query.

Assume that your output is going to be displayed on an interative UI. The user
will interact with you through a set of multiple choice questions.

Each question should be related to the original query from the user. No question
should ask the user about any other topic or to start a new conversation.

After the user has answered your follow-up questions, please provide a
description of a product that will help the user with their original query.
This product description should NOT include another question for the user. The
product description should NOT include the name of any specific product.
`;

    const { output, messages } = await ai.generate({
      // System is only supported in the first prompt in the history.
      ...(history.length == 0 ? { system } : {}),
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

startFlowServer({
  flows: [greenThumb],
});

import { startFlowServer } from '@genkit-ai/express';
import { gemini20Flash, googleAI } from "@genkit-ai/googleai";
import { genkit, z } from "genkit";

const ai = genkit({
  plugins: [googleAI()],
  model: gemini20Flash,
});

// Two flows:
// flow #1: for the Q&A between the model and the user
// flow #2: building the RAG index from the product catalog

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
      // System is only supported in the first prompt in the history.
      ...(history.length == 0 ? { system } : {}),
      prompt: [
        ...(input.image ? [{ media: { url: input.image } }] : []),
        { text: query },
      ],
      messages: history,
      output: { schema: GtOutputSchema },
    });

    const moreQuestions = (output?.optionsForUser?.length ?? 0) > 0;
    // TODO: if there are no more questions, feed the llmResponse into RAG to
    // find a matching product.

    return { output: output!, history: messages };
  },
);

startFlowServer({
  flows: [greenThumb],
});

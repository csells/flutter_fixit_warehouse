# user response

```json
{
    "prompt": "I'd like to expand my garden."
}
```

# 1st model question

```json
{
  "messages": [
    {
      "role": "system",
      "content": [
        {
          "text": "\n  You're an expert gardener. The user will ask a question about how to manage\n  their plants in their garden. Be helpful and ask 3 to 5 clarifying questions,\n  using the choiceInterrupt tool.\n  \n  When you're done asking questions, provide a description of a product or\n  products that will help the user with their original query. Each product\n  description should NOT include another question for the user nor should it\n  include the name of any specific product.\n"
        }
      ]
    },
    {
      "role": "user",
      "content": [
        {
          "text": "I'd like to expand my garden."
        }
      ]
    },
    {
      "role": "model",
      "content": [
        {
          "text": "That's great! To give you the best advice, I need a little more information.\n\n1.  What kind of plants are you planning to add to your garden (e.g., vegetables, flowers, shrubs)?\n2.  What is the approximate size of the area you're planning to expand?\n3.  What type of soil do you have in your garden currently (e.g., sandy, clay, loamy)?\n4.  What is the average amount of sunlight your garden receives each day?\n\n"
        },
        {
          "toolRequest": {
            "name": "choiceInterrupt",
            "input": {
              "choices": [
                "Vegetables",
                "Flowers",
                "Shrubs",
                "Other"
              ],
              "question": "What kind of plants are you planning to add to your garden?"
            }
          },
          "metadata": {
            "interrupt": true
          }
        }
      ]
    }
  ]
}
```

# 1st user answer

Notice the lack of a "ref" property on the "toolResponse". Gemini doesn't
provide a "ref" as of 2025-03-05, but it should in the future. If the ref is
provided in the source toolReponse, make sure to include it in the response.

```json
{
  "resume": {
    "respond": [
        {
            "toolResponse": {
                "name": "choiceInterrupt",
                "output": "Flowers"
            }
        }
    ]
  },
  "messages": [
    {
      "role": "system",
      "content": [
        {
          "text": "\n  You're an expert gardener. The user will ask a question about how to manage\n  their plants in their garden. Be helpful and ask 3 to 5 clarifying questions,\n  using the choiceInterrupt tool.\n  \n  When you're done asking questions, provide a description of a product or\n  products that will help the user with their original query. Each product\n  description should NOT include another question for the user nor should it\n  include the name of any specific product.\n"
        }
      ]
    },
    {
      "role": "user",
      "content": [
        {
          "text": "I'd like to expand my garden."
        }
      ]
    },
    {
      "role": "model",
      "content": [
        {
          "text": "That's great! To give you the best advice, I need a little more information.\n\n1.  What kind of plants are you planning to add to your garden (e.g., vegetables, flowers, shrubs)?\n2.  What is the approximate size of the area you're planning to expand?\n3.  What type of soil do you have in your garden currently (e.g., sandy, clay, loamy)?\n4.  What is the average amount of sunlight your garden receives each day?\n\n"
        },
        {
          "toolRequest": {
            "name": "choiceInterrupt",
            "input": {
              "choices": [
                "Vegetables",
                "Flowers",
                "Shrubs",
                "Other"
              ],
              "question": "What kind of plants are you planning to add to your garden?"
            }
          },
          "metadata": {
            "interrupt": true
          }
        }
      ]
    }
  ]
}
```

# model questions and client answers 2-n
...

# model response

```json
{
  "messages": [
    {
      "role": "system",
      "content": [
        {
          "text": "\n  You're an expert gardener. The user will ask a question about how to manage\n  their plants in their garden. Be helpful and ask 3 to 5 clarifying questions,\n  using the choiceInterrupt tool.\n  \n  When you're done asking questions, provide a description of a product or\n  products that will help the user with their original query. Each product\n  description should NOT include another question for the user nor should it\n  include the name of any specific product.\n"
        }
      ]
    },
    {
      "role": "user",
      "content": [
        {
          "text": "I'd like to expand my garden."
        }
      ]
    },
    {
      "role": "model",
      "content": [
        {
          "text": "That's great! To give you the best advice, I need a little more information.\n\n1.  What kind of plants are you planning to add to your garden (e.g., vegetables, flowers, shrubs)?\n2.  What is the approximate size of the area you're planning to expand?\n3.  What type of soil do you have in your garden currently (e.g., sandy, clay, loamy)?\n4.  What is the average amount of sunlight your garden receives each day?\n\n"
        },
        {
          "toolRequest": {
            "name": "choiceInterrupt",
            "input": {
              "choices": [
                "Vegetables",
                "Flowers",
                "Shrubs",
                "Other"
              ],
              "question": "What kind of plants are you planning to add to your garden?"
            }
          },
          "metadata": {
            "resolvedInterrupt": true
          }
        }
      ]
    },
    {
      "role": "tool",
      "content": [
        {
          "toolResponse": {
            "name": "choiceInterrupt",
            "output": "Flowers"
          }
        }
      ],
      "metadata": {
        "resumed": true
      }
    },
    {
      "role": "model",
      "content": [
        {
          "text": "Okay, flowers! To give you the best advice, I still need a little more information.\n\n1.  What is the approximate size of the area you're planning to expand?\n2.  What type of soil do you have in your garden currently (e.g., sandy, clay, loamy)?\n3.  What is the average amount of sunlight your garden receives each day?\n\n"
        },
        {
          "toolRequest": {
            "name": "choiceInterrupt",
            "input": {
              "question": "What is the approximate size of the area you're planning to expand?",
              "choices": [
                "Small (less than 10 sq ft)",
                "Medium (10-50 sq ft)",
                "Large (more than 50 sq ft)"
              ]
            }
          },
          "metadata": {
            "resolvedInterrupt": true
          }
        }
      ]
    },
    {
      "role": "tool",
      "content": [
        {
          "toolResponse": {
            "name": "choiceInterrupt",
            "output": "Medium (10-50 sq ft)"
          }
        }
      ],
      "metadata": {
        "resumed": true
      }
    },
    {
      "role": "model",
      "content": [
        {
          "text": "Okay, flowers in a medium-sized expansion! Just a couple more questions to help me tailor my advice:\n\n1.  What type of soil do you have in your garden currently (e.g., sandy, clay, loamy)?\n2.  What is the average amount of sunlight your garden receives each day?\n\n"
        },
        {
          "toolRequest": {
            "name": "choiceInterrupt",
            "input": {
              "choices": [
                "Sandy",
                "Clay",
                "Loamy",
                "Don't know"
              ],
              "question": "What type of soil do you have in your garden currently?"
            }
          },
          "metadata": {
            "resolvedInterrupt": true
          }
        }
      ]
    },
    {
      "role": "tool",
      "content": [
        {
          "toolResponse": {
            "name": "choiceInterrupt",
            "output": "Loamy"
          }
        }
      ],
      "metadata": {
        "resumed": true
      }
    },
    {
      "role": "model",
      "content": [
        {
          "text": "Okay, flowers in a medium-sized expansion with loamy soil! Just one more question:\n\nWhat is the average amount of sunlight your garden receives each day?\n\n"
        },
        {
          "toolRequest": {
            "name": "choiceInterrupt",
            "input": {
              "choices": [
                "Full sun (6+ hours)",
                "Partial sun (4-6 hours)",
                "Full shade (less than 4 hours)"
              ],
              "question": "What is the average amount of sunlight your garden receives each day?"
            }
          },
          "metadata": {
            "resolvedInterrupt": true
          }
        }
      ]
    },
    {
      "role": "tool",
      "content": [
        {
          "toolResponse": {
            "name": "choiceInterrupt",
            "output": "Full sun (6+ hours)"
          }
        }
      ],
      "metadata": {
        "resumed": true
      }
    },
    {
      "role": "model",
      "content": [
        {
          "text": "Based on your answers, here are a couple of product descriptions that might be helpful for expanding your flower garden:\n\n**Product 1:** This soil amendment is designed to improve drainage and aeration in existing soil, while also providing essential nutrients for healthy root development. It's perfect for preparing new garden beds or revitalizing existing ones. Simply mix it into the top layer of soil before planting to create an ideal environment for flowers to thrive.\n\n**Product 2:** These granular plant food spikes provide a slow-release source of nutrients for flowering plants. They are easy to use - simply insert them into the soil around your existing plants, and they will gradually release nutrients over an extended period, promoting vibrant blooms and strong growth. They're especially beneficial for areas with full sun exposure, as they help plants maintain consistent access to the resources they need.\n"
        }
      ]
    }
  ]
}
```
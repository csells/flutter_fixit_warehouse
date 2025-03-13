import 'dart:convert';

import 'package:flutter_fix_warehouse/greenthumb/data.dart';
import 'package:flutter_fix_warehouse/views/view_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('testing a full chat with multiple interrupts and tool calls', () {
    final json = jsonDecode(realFullChat);

    final rawMessages = <RawMessage>[];
    final n = json['result']['messages'].length;
    for (var i = 0; i < n; i++) {
      rawMessages.add(RawMessage.fromJson(json['result']['messages'][i]));
    }

    // expect: system, user request, 3x interrupt request+response, 1x tool request+response, model
    expect(rawMessages.length, 11);

    // expect: user, 3x interrupt request/response, model
    final messages = Message.messagesFrom(rawMessages);
    expect(messages.length, 5);
  });
}

const realFullChat = r'''
{
  "result": {
    "messages": [
      {
        "role": "system",
        "content": [
          {
            "text": "\nYou're an expert gardener. The user will ask a question about how to manage\ntheir plants in their garden. Be helpful and ask 3 to 5 clarifying questions,\nusing the choiceInterrupt, imageInterrupt, and rangeInterrupt tools. Do NOT ask\nthe user questions without using a tool; they will not be able to respond.\n\nWhen you're done asking questions, produce the description of a product or\nproducts that will help the user with their original query. Use the\nproductFromDescriptionTool to look up the product details to include in your\nresponse.\n\nImages returned from the productFromDescriptionTool should be displayed in a\nMarkdown image tag.\n\nDO NOT make up any product names or details; ONLY use the\nproductFromDescriptionTool tool to get the product details.\n\nDO NOT use real-world product names; only use the product names returned by the \nproductFromDescriptionTool tool.\n\nThe response should be a summary of your final recommendation as well as a list\nof products incorporating the product name, manufacturer, cost, and image in a\npleasant format.\n"
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
            "text": "Expanding a garden can be an exciting project! To give you the best advice, I need a little more information.\n\nFirst, could you tell me what kind of plants you are planning to grow in your expanded garden?\n"
          },
          {
            "toolRequest": {
              "name": "choiceInterrupt",
              "input": {
                "question": "What kind of plants are you planning to grow in your expanded garden?",
                "choices": [
                  "Vegetables",
                  "Flowers",
                  "Fruits",
                  "Herbs",
                  "A mix of different plants"
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
            "text": "Got it, you're planning on growing flowers!\n\nTo help me understand the scope of your expansion, on a scale of 1 to 10, with 1 being a small expansion and 10 being a major overhaul, how large is the expansion you're planning?\n"
          },
          {
            "toolRequest": {
              "name": "rangeInterrupt",
              "input": {
                "question": "On a scale of 1 to 10, with 1 being a small expansion and 10 being a major overhaul, how large is the expansion you're planning?",
                "choices": [],
                "min": 1,
                "max": 10
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
              "name": "rangeInterrupt",
              "output": "2"
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
            "text": "Ok, so a fairly small expansion focusing on flowers. To make sure I can give you the most tailored advice, could you take a picture of the area where you are planning to expand your garden?\n"
          },
          {
            "toolRequest": {
              "name": "imageInterrupt",
              "input": {
                "question": "Could you take a picture of the area where you are planning to expand your garden?",
                "choices": []
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
              "name": "imageInterrupt",
              "output": "data:image/jpeg;base64,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"
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
            "text": "Thanks for the information and the picture! Based on your answers, I recommend focusing on soil enrichment and selecting the right flower seeds for your garden expansion. Here are a couple of products that should help:\n\n1.  **MiracleGro Flower Soil:** This soil is designed to help flowers grow.\n"
          },
          {
            "toolRequest": {
              "name": "productFromDescriptionTool",
              "input": {
                "description": "MiracleGro Flower Soil"
              }
            }
          },
          {
            "text": "\n2.  **Flower Power Seed Mix:** This seed mix contains a variety of flower seeds.\n"
          },
          {
            "toolRequest": {
              "name": "productFromDescriptionTool",
              "input": {
                "description": "Flower Power Seed Mix"
              }
            }
          }
        ]
      },
      {
        "role": "tool",
        "content": [
          {
            "toolResponse": {
              "name": "productFromDescriptionTool",
              "output": {
                "product": "All-Purpose Garden Soil",
                "manufacturer": "EarthWorks",
                "cost": 8,
                "image": "EarthWorks-Soil_Fertilizers-All_Purpose_Garden_Soil.png",
                "reason": "Matched based on: MiracleGro Flower Soil"
              }
            }
          },
          {
            "toolResponse": {
              "name": "productFromDescriptionTool",
              "output": {
                "product": "Sunflower Seeds (Giant)",
                "manufacturer": "SunGrow Seeds",
                "cost": 5,
                "image": "SunGrow_Seeds-Plants_Seeds-Sunflower_Seeds_Giant.png",
                "reason": "Matched based on: Flower Power Seed Mix"
              }
            }
          }
        ]
      },
      {
        "role": "model",
        "content": [
          {
            "text": "I recommend enriching the soil in your expansion area with **All-Purpose Garden Soil** from EarthWorks. It costs $8 and here is an image of the product:\n\n"
          }
        ]
      }
    ]
  }
}
''';

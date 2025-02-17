import 'package:flutter/foundation.dart' show ChangeNotifier;

class ConversationData extends ChangeNotifier {
  List<ChatMessage> messages = [
    ChatMessage(
      text:
          "Based on the leaf markings, that's a Calathea. I've added it to your plants.\nThe edges of the leaves are brown and crispy, indicating dehydration. How often are you watering this plant?",
      isUser: false,
      type: ChatMessageType.question,
      options: [
        'A few times a month',
        'A few times a week',
        'A few times a day',
      ],
    ),
  ];

  void addResponse(String response) {
    messages = [
      ...messages,
      ChatMessage(text: response, isUser: true, type: ChatMessageType.answer),
    ];
    messages = [
      ...messages,
      ChatMessage(
        text: 'Try watering daily for the next 3 weeks:',
        isUser: false,
        type: ChatMessageType.recommendation,
        reminder: 'Water Calathea #1\nDaily for 3 weeks',
        plantFood: 'Miracle-Gro Indoor Plant Food\n\$8.97',
        followUp: "We'll reassess in 3 weeks!",
      ),
    ];
    notifyListeners();
  }
}

enum ChatMessageType { question, answer, recommendation }

class ChatMessage {
  ChatMessage({
    required this.text,
    required this.isUser,
    required this.type,
    this.options,
    this.reminder,
    this.plantFood,
    this.followUp,
  });
  final String text;
  final bool isUser;
  final ChatMessageType type;
  List<String>? options;
  String? reminder;
  String? plantFood;
  String? followUp;
}

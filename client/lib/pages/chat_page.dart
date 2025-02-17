import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fix_warehouse/pages/gardening_page.dart';
import 'package:provider/provider.dart';

import '../data/chat_data.dart';

class ChatPage extends StatelessWidget {
  const ChatPage({super.key, this.action, required this.image});

  final GardeningAction? action;
  final XFile image;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Calathea #1')),
    body: Consumer<ConversationData>(
      builder:
          (context, conversationData, child) => Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: conversationData.messages.length,
                  itemBuilder: (context, index) {
                    final message = conversationData.messages[index];

                    if (message.type == ChatMessageType.question) {
                      return _QuestionView(message: message);
                    } else if (message.type == ChatMessageType.answer) {
                      return _AnswerView(message: message);
                    } else {
                      return _RecommendationView(message: message);
                    }
                  },
                ),
              ),
            ],
          ),
    ),
  );
}

class _QuestionView extends StatelessWidget {
  const _QuestionView({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              backgroundColor: Colors.green,
              child: Icon(Icons.eco, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  // color: Colors.green.shade50,
                  borderRadius: const BorderRadius.all(Radius.circular(12)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(message.text),
                ),
              ),
            ),
          ],
        ),
        if (message.options != null)
          Padding(
            padding: const EdgeInsets.only(left: 48),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  message.options!
                      .map<Widget>(
                        (option) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            onPressed:
                                () => context
                                    .read<ConversationData>()
                                    .addResponse(option),
                            child: Text(option),
                          ),
                        ),
                      )
                      .toList(),
            ),
          ),
      ],
    ),
  );
}

class _AnswerView extends StatelessWidget {
  const _AnswerView({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(8).copyWith(left: 48),
    child: Align(
      alignment: Alignment.topLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: const BorderRadius.all(Radius.circular(12)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Text(message.text),
        ),
      ),
    ),
  );
}

class _RecommendationView extends StatelessWidget {
  const _RecommendationView({required this.message});
  final ChatMessage message;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DecoratedBox(
          decoration: const BoxDecoration(
            color: Colors.lightGreen,
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(message.text),
          ),
        ),
        if (message.reminder != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.blue[100],
                border: Border.all(color: Colors.blue, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    const Icon(Icons.alarm_add, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text('Add reminder\n${message.reminder!}'),
                  ],
                ),
              ),
            ),
          ),
        if (message.plantFood != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.orange, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Image.network(
                      'https://www.gstatic.com/flutter-onestack-prototype/genui/example_1.jpg',
                      width: 40,
                      height: 40,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "If you're worried about losing the plant, try:\n${message.plantFood!}",
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (message.followUp != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Text(message.followUp!),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              side: const BorderSide(width: 1, color: Colors.grey),
            ),
            onPressed: () {},
            child: const Text(
              'Ask a follow up',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () {},
            child: const Text('Done for now'),
          ),
        ),
      ],
    ),
  );
}

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';

import '../chat_service.dart';
import '../gardening_action.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.action, required this.image});

  final GardeningAction action;
  final XFile image;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _title = ValueNotifier('Loading...');
  final _chat = Chat();
  final _selectedOptions = <LlmQuestion, String>{};

  @override
  void initState() {
    super.initState();

    () async {
      await _chat.sendMessage(widget.action.prompt, widget.image);
      final title = _chat.turns.whereType<LlmQuestion>().last.titleForChat;
      _title.value = title ?? widget.action.chatTitle;
    }();
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<String>(
    valueListenable: _title,
    builder:
        (context, title, child) => Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.green,
            title: Text(title, style: const TextStyle(color: Colors.white)),
          ),
          body: child,
        ),
    child: ListenableBuilder(
      listenable: _chat,
      builder: (context, child) {
        final llmTurns = _chat.turns.whereType<LlmQuestion>().toList();
        return ListView.builder(
          itemCount: llmTurns.length,
          itemBuilder: (context, index) {
            final turn = llmTurns[index];

            return LlmQuestionView(
              text: turn.llmResponse,
              options: turn.optionsForUser,
              onPressed: (option) => _optionSelected(turn, option),
              selectedOption: _selectedOptions[turn],
            );
          },
        );
      },
    ),
  );

  void _optionSelected(LlmQuestion turn, String option) {
    setState(() => _selectedOptions[turn] = option);
    _chat.sendMessage(option);
  }
}

class LlmQuestionView extends StatelessWidget {
  const LlmQuestionView({
    super.key,
    required this.text,
    required this.options,
    required this.onPressed,
    this.selectedOption,
  });

  final String text;
  final List<String> options;
  final void Function(String) onPressed;
  final String? selectedOption;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.green[50],
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.eco, color: Colors.green, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(height: 1.4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 40.0), // Align with text
          child: Center(
            child: Column(
              spacing: 8,
              children: [
                for (final option in options)
                  SizedBox(
                    width: 300,
                    child: ElevatedButton(
                      onPressed:
                          selectedOption == null || selectedOption == option
                              ? () => onPressed(option)
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                      child: Text(option, textAlign: TextAlign.center),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

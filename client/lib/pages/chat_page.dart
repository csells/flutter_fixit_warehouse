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
  final _title = ValueNotifier('Untitled');
  final _chat = Chat();
  final _selectedOptions = <ModelTurn, String>{};

  @override
  void initState() {
    super.initState();
    _chat.sendMessage(widget.action.prompt, widget.image);
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<String>(
    valueListenable: _title,
    builder:
        (context, title, child) =>
            Scaffold(appBar: AppBar(title: Text(title)), body: child),
    child: ListenableBuilder(
      listenable: _chat,
      builder: (context, child) {
        final llmTurns = _chat.turns.whereType<ModelTurn>().toList();
        return ListView.builder(
          itemCount: llmTurns.length,
          itemBuilder: (context, index) {
            final turn = llmTurns[index];
            final selectedOption = _selectedOptions[turn];

            return ModelTurnWidget(
              llmQuery: turn.llmQuery,
              options: turn.optionsForUser,
              onPressed:
                  selectedOption == null
                      ? (option) => _optionSelected(turn, option)
                      : (_) {},
              selectedOption: selectedOption,
            );
          },
        );
      },
    ),
  );

  void _optionSelected(ModelTurn turn, String option) {
    _selectedOptions[turn] = option;
    _chat.sendMessage(option);
  }
}

class ModelTurnWidget extends StatelessWidget {
  const ModelTurnWidget({
    super.key,
    required this.llmQuery,
    required this.options,
    this.onPressed,
    this.selectedOption,
  });

  final String llmQuery;
  final List<String> options;
  final void Function(String)? onPressed;
  final String? selectedOption;

  @override
  Widget build(BuildContext context) {
    return Padding(
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
                  llmQuery,
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
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final option in options)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          onPressed != null ? () => onPressed!(option) : null,
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
        ],
      ),
    );
  }
}

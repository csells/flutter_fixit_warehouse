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
            return ModelTurnWidget(
              llmQuery: turn.llmQuery,
              options: turn.optionsForUser,
              onPressed: (query) => _submitQuery(query),
            );
          },
        );
      },
    ),
  );

  void _submitQuery(String query) => _chat.sendMessage(query);
}

class ModelTurnWidget extends StatelessWidget {
  final String llmQuery;
  final List<String> options;
  final void Function(String) onPressed;

  const ModelTurnWidget({
    super.key,
    required this.llmQuery,
    required this.options,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(llmQuery),
        ...[
          for (final option in options)
            TextButton(onPressed: () => onPressed(option), child: Text(option)),
        ],
      ],
    );
  }
}

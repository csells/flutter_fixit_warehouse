import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../greenthumb/model.dart';

class ToolChoicesView extends StatelessWidget {
  ToolChoicesView({
    required MessageUnit unit,
    required this.onPrompt,
    super.key,
  }) : question = unit.m1.content.first.text,
       choices = unit.m1.content.first.toolRequest.input.choices,
       selectedOption = unit.m2!.content.first.toolResponse.output;

  final String question;
  final Iterable<String> choices;
  final String? selectedOption;
  final void Function(String)? onPrompt;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
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
              child: MarkdownBody(
                data: question,
                styleSheet: MarkdownStyleSheet(
                  p: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(height: 1.4),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 40.0), // Align with text
          child: Center(
            child: Column(
              children: [
                for (final option in choices)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: SizedBox(
                      width: 300,
                      child: ElevatedButton(
                        onPressed:
                            selectedOption == null && onPrompt != null
                                ? () => onPrompt!(option)
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
                  ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

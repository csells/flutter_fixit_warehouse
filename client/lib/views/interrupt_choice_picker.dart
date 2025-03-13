import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../greenthumb/service.dart';
import 'gt_button.dart';
import 'view_model.dart';

class InterruptChoicePicker extends StatelessWidget {
  InterruptChoicePicker({
    required InterruptMessage message,
    required this.onResume,
    super.key,
  }) : question = message.text,
       choices = message.toolRequest!.input.choices,
       selectedValue = message.toolResponse?.output,
       toolRef = message.toolRequest!.ref,
       toolName = message.toolRequest!.name;

  final String question;
  final Iterable<String> choices;
  final String? selectedValue;
  final String? toolRef;
  final String toolName;
  final ToolResumeCallback? onResume;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(32),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        MarkdownBody(
          data: question,
          styleSheet: MarkdownStyleSheet(
            p: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.4),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 40.0),
          child: Center(
            child: Column(
              children: [
                for (final choice in choices)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: SizedBox(
                      width: 300,
                      child: GtButton(
                        onPressed:
                            selectedValue == null && onResume != null
                                ? () => onResume!(
                                  ref: toolRef,
                                  name: toolName,
                                  output: choice,
                                )
                                : null,

                        child: Text(choice, textAlign: TextAlign.center),
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

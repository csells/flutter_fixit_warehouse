import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../greenthumb/model.dart';
import 'view_model.dart';

class ToolChoicePicker extends StatelessWidget {
  ToolChoicePicker({
    required MessageUnit unit,
    required this.onResume,
    super.key,
  }) : assert(unit.type == MessageUnitType.tool),
       question = unit.text,
       choices = unit.toolRequest.input.choices,
       selectedValue = unit.toolResponse?.output,
       toolRef = unit.toolRequest.ref,
       toolName = unit.toolRequest.name;

  final String question;
  final Iterable<String> choices;
  final String? selectedValue;
  final String? toolRef;
  final String toolName;
  final void Function(ToolResponse)? onResume;

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
                      child: ElevatedButton(
                        onPressed:
                            selectedValue == null && onResume != null
                                ? () => onResume!(
                                  ToolResponse(
                                    ref: toolRef,
                                    name: toolName,
                                    output: choice,
                                  ),
                                )
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

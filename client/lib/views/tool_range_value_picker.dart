import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../greenthumb/service.dart';
import 'gt_button.dart';
import 'view_model.dart';

class ToolRangeValuePicker extends StatefulWidget {
  ToolRangeValuePicker({
    required MessageUnit unit,
    required this.onResume,
    super.key,
  }) : assert(unit.type == MessageUnitType.tool),
       assert(unit.toolRequest.input.min != null),
       assert(unit.toolRequest.input.max != null),
       question = unit.text,
       min = unit.toolRequest.input.min!,
       max = unit.toolRequest.input.max!,
       selectedValue = int.tryParse(unit.toolResponse?.output ?? ''),
       toolRef = unit.toolRequest.ref,
       toolName = unit.toolRequest.name;

  final String question;
  final int min;
  final int max;
  final int? selectedValue;
  final String? toolRef;
  final String toolName;
  final ToolResumeCallback? onResume;

  @override
  State<ToolRangeValuePicker> createState() => _ToolRangeValuePickerState();
}

class _ToolRangeValuePickerState extends State<ToolRangeValuePicker> {
  late int _currentValue;

  @override
  void initState() {
    super.initState();

    _currentValue =
        widget.selectedValue ?? ((widget.min + widget.max) / 2).round();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(32),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        MarkdownBody(
          data: widget.question,
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
                Slider(
                  value: _currentValue.toDouble(),
                  min: widget.min.toDouble(),
                  max: widget.max.toDouble(),
                  divisions: min(widget.max - widget.min, 10),
                  label: _currentValue.toString(),
                  onChanged:
                      (value) => setState(() => _currentValue = value.round()),
                  activeColor: Colors.green,
                ),
                Text(
                  _currentValue.toString(),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                GtButton(
                  onPressed:
                      widget.onResume == null
                          ? null
                          : () {
                            widget.onResume!(
                              ref: widget.toolRef,
                              name: widget.toolName,
                              output: _currentValue.toString(),
                            );
                          },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

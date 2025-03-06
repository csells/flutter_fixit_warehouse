import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'view_model.dart';

class ModelResponseView extends StatelessWidget {
  ModelResponseView({required this.unit, super.key})
    : assert(unit.type == MessageUnitType.model);

  final MessageUnit unit;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(32),
    child: MarkdownBody(
      data: unit.text,
      styleSheet: MarkdownStyleSheet(
        p: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.4),
      ),
    ),
  );
}

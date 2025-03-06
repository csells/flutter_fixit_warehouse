import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../greenthumb/model.dart';

class ModelResponseView extends StatelessWidget {
  const ModelResponseView({required this.unit, super.key});

  final MessageUnit unit;

  @override
  Widget build(BuildContext context) => MarkdownBody(data: unit.text);
}

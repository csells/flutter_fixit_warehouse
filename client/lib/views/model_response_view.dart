import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'view_model.dart';

class ModelResponseView extends StatelessWidget {
  const ModelResponseView({required this.message, super.key});

  final ModelResponse message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(32),
    child: SingleChildScrollView(
      child: MarkdownBody(
        data: message.text,
        styleSheet: MarkdownStyleSheet(
          p: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.4),
        ),
        imageBuilder:
            // TODO: resolve the image URL
            (uri, title, alt) => Placeholder(child: Text(uri.toString())),
      ),
    ),
  );
}

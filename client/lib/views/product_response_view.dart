// json access
// ignore_for_file: avoid_dynamic_calls

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import '../data/product_data.dart';

class ProductResponseView extends StatelessWidget {
  const ProductResponseView({required this.response, super.key});

  final String response;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    try {
      final map = jsonDecode(response);
      final productsWithText = map['products'] as List<dynamic>;
      final finalText = map['text'] as String;

      for (final recipeWithText in productsWithText) {
        // extract the text before the recipe
        final text = recipeWithText['text'] as String;
        if (text.isNotEmpty) children.add(MarkdownBody(data: text));

        // extract the recipe
        final json = recipeWithText['recipe'] as Map<String, dynamic>;
        final product = Product.fromJson(json);
        children.add(const SizedBox(height: 16));
        children.add(
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 50,
                    height: 50,
                    child: Placeholder(child: Text('TODO: Image')),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    product.productName,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              Text(product.shortDescription),
              Text(product.manufacturer),
              Text('Cost: ${product.costUsd}'),
            ],
          ),
        );
      }

      // add the remaining text
      if (finalText.isNotEmpty) children.add(MarkdownBody(data: finalText));
    }
    // want to catch everything
    // ignore: avoid_catches_without_on_clauses
    catch (e) {
      children.add(Text('Error: $e'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}

import 'package:flutter/material.dart';

import '../data/product_data.dart';

class ProductView extends StatelessWidget {
  const ProductView({
    required this.product,
    required this.expanded,
    required this.onExpansionChanged,
    super.key,
  });

  final Product product;
  final bool expanded;
  final ValueChanged<bool>? onExpansionChanged;

  @override
  Widget build(BuildContext context) => Card(
    child: Column(
      children: [
        ExpansionTile(
          leading: const SizedBox(
            width: 50,
            height: 50,
            child: Placeholder(child: Text('TODO: Image')),
          ),
          title: Text(product.productName),
          subtitle: Text(product.manufacturer),
          initiallyExpanded: expanded,
          onExpansionChanged: onExpansionChanged,
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text(product.shortDescription),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Cost: \$${product.costUsd}'),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

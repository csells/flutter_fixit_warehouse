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
          leading: const Placeholder(child: Text('TODO: Image')),
          title: Text(product.productName),
          subtitle: Text(product.manufacturer),
          initiallyExpanded: expanded,
          onExpansionChanged: onExpansionChanged,
          children: [
            Text(product.shortDescription),
            Text('Cost: ${product.costUsd}'),
          ],
        ),
      ],
    ),
  );
}

import 'package:flutter/material.dart';

import '../data/product_data.dart';
import '../data/product_repository.dart';
import 'product_view.dart';

class ProductListView extends StatefulWidget {
  const ProductListView({
    required this.repository,
    required this.searchText,
    super.key,
  });

  final ProductRepository repository;
  final String searchText;

  @override
  _ProductListViewState createState() => _ProductListViewState();
}

class _ProductListViewState extends State<ProductListView> {
  final _expanded = <int, bool>{};

  Iterable<Product> _filteredProducts(Iterable<Product> products) =>
      products
          .where(
            (product) =>
                product.productName.toLowerCase().contains(
                  widget.searchText.toLowerCase(),
                ) ||
                product.manufacturer.toLowerCase().contains(
                  widget.searchText.toLowerCase(),
                ),
          )
          .toList()
        ..sort(
          (a, b) => a.productName.toLowerCase().compareTo(
            b.productName.toLowerCase(),
          ),
        );

  @override
  Widget build(BuildContext context) => ListView(
    children: [
      for (final product in _filteredProducts(widget.repository.products))
        ProductView(
          key: ValueKey(product.id),
          product: product,
          expanded: _expanded[product.id] ?? false,
          onExpansionChanged: (expanded) => _onExpand(product.id, expanded),
        ),
    ],
  );

  void _onExpand(int productId, bool expanded) =>
      _expanded[productId] = expanded;
}

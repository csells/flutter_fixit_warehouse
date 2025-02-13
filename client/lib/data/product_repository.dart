import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import 'product_data.dart';

class ProductRepository {
  ProductRepository._(List<Product> products) : _products = products;
  final List<Product> _products;

  static const _productsAsset = 'assets/products.json';
  static ProductRepository? _instance;

  static Future<ProductRepository> get instance async {
    if (_instance == null) {
      final contents = await rootBundle.loadString(_productsAsset);
      final jsonList = json.decode(contents) as List;
      final products = jsonList.map((json) => Product.fromJson(json)).toList();
      _instance = ProductRepository._(products);
    }

    return _instance!;
  }

  Iterable<Product> get products => _products;

  Product getProduct(int productId) =>
      _products.singleWhere((p) => p.id == productId);
}

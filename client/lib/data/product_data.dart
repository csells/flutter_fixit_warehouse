import 'dart:convert';

class Product {
  Product({
    required this.productName,
    required this.manufacturer,
    required this.shortDescription,
    required this.costUsd,
    required this.imageFile,
    required this.id,
  });

  factory Product.fromRawJson(String str) => Product.fromJson(json.decode(str));

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    productName: json['Product Name'],
    manufacturer: json['Manufacturer'],
    shortDescription: json['Short Description'],
    costUsd: json['Cost (USD)'],
    imageFile: json['imageFile'],
    id: json['id'],
  );
  final String productName;
  final String manufacturer;
  final String shortDescription;
  final int costUsd;
  final String imageFile;
  final int id;

  String toRawJson() => json.encode(toJson());

  Map<String, dynamic> toJson() => {
    'Product Name': productName,
    'Manufacturer': manufacturer,
    'Short Description': shortDescription,
    'Cost (USD)': costUsd,
    'imageFile': imageFile,
    'id': id,
  };
}

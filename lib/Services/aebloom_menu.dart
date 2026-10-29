// To parse this JSON data, do
//
//     final aeBloomProducts = aeBloomProductsFromJson(jsonString);

import 'dart:convert';

AEBloomProducts aeBloomProductsFromJson(String str) => AEBloomProducts.fromJson(json.decode(str));

String aeBloomProductsToJson(AEBloomProducts data) => json.encode(data.toJson());

class AEBloomProducts {
  AEBloomProducts({
    required this.data,
  });

  final List<ProductDatum> data;

  factory AEBloomProducts.fromJson(Map<String, dynamic> json) => AEBloomProducts(
        data: List<ProductDatum>.from(json["data"].map((x) => ProductDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class ProductDatum {
  ProductDatum({
    required this.id,
    required this.productName,
    required this.flowerType,
    required this.productImage,
    required this.price,
    required this.inStock,
  });

  final int id;
  final String productName;
  final String flowerType;
  final String productImage;
  final double price;
  final bool inStock;

  factory ProductDatum.fromJson(Map<String, dynamic> json) => ProductDatum(
        id: json["id"],
        productName: json["productName"],
        flowerType: json["flowerType"],
        productImage: json["productImage"],
        price: (json["price"] as num).toDouble(),
        inStock: json["inStock"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "productName": productName,
        "flowerType": flowerType,
        "productImage": productImage,
        "price": price,
        "inStock": inStock,
      };
}
import 'dart:convert';

AEBloomProducts aeBloomProductsFromJson(String source) =>
    AEBloomProducts.fromJson(json.decode(source) as Map<String, dynamic>);

class AEBloomProducts {
  const AEBloomProducts({required this.data});

  final List<ProductDatum> data;

  factory AEBloomProducts.fromJson(Map<String, dynamic> json) {
    return AEBloomProducts(
      data: (json['data'] as List<dynamic>)
          .map((item) => ProductDatum.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

class ProductDatum {
  const ProductDatum({
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

  factory ProductDatum.fromJson(Map<String, dynamic> json) {
    return ProductDatum(
      id: json['id'] as int,
      productName: json['productName'] as String,
      flowerType: json['flowerType'] as String,
      productImage: json['productImage'] as String,
      price: (json['price'] as num).toDouble(),
      inStock: json['inStock'] as bool,
    );
  }
}

import 'package:shopwiz/models/product_model.dart';

class Store {
  final String storeId;
  final String imagePath;
  final String storeName;
  final String storeAddress;
    late final String status;
  final double latitude;
  final double longitude;
  final List<Product> products;

  Store({
    required this.storeId,
    required this.imagePath,
    required this.storeName,
    required this.storeAddress,
    required this.latitude,
    required this.longitude,
    required this.products,
  });

  factory Store.fromMap(Map<String, dynamic> map) {
    List<Product> products = [];
    if (map['products'] != null) {
      products = List<Product>.from(
          map['products'].map((productMap) => Product.fromMap(productMap)));
    }

    return Store(
      storeId: map['sid'] ?? '',
      imagePath: map['simageurl'] ?? '',
      storeName: map['sname'] ?? '',
      storeAddress: map['saddress'] ?? '',
      latitude: map['latitude'] ?? 0.0,
      longitude: map['longitude'] ?? 0.0,
      products: products,
    );
  }
}

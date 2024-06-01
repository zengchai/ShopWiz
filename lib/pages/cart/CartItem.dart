import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String pid;
  final String name;
  final String image;
  final int quantity;
  final double price;
  String _store; // Private field to store the store name
  String _storeId; // Private field to store the store ID

  CartItem({
    required this.pid,
    required this.name,
    required this.image,
    required this.quantity,
    required this.price,
    required String store, // Change store to be required in the constructor
    required String storeId, // New field for store ID
  })  : _store = store, // Initialize _store with the provided store value
        _storeId = storeId; // Initialize _storeId with the provided store ID value

  // Getter method for store
  String get store => _store;

  // Setter method for store
  set store(String storeName) {
    _store = storeName;
  }

  // Getter method for store ID
  String get storeId => _storeId;

  // Setter method for store ID
  set storeId(String id) {
    _storeId = id;
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      pid: json['pid'],
      name: json['name'],
      image: json['image'],
      quantity: json['quantity'],
      price: json['price'],
      store: json['store'], // Map the store field
      storeId: json['storeId'], // Map the store ID field
    );
  }

  factory CartItem.fromSnapshot(DocumentSnapshot snapshot) {
  Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
  return CartItem(
    pid: snapshot.id,
    name: data['name'] ?? '',
    image: data['image'] ?? '',
    quantity: data['quantity'] ?? 0,
    price: data['price'] ?? 0.0,
    store: data['store'] ?? '', // Map the store field
    storeId: data['storeId'] ?? '', // Map the store ID field
  );
}
  Map<String, dynamic> toJson() {
    return {
      'pid': pid,
      'name': name,
      'image': image,
      'quantity': quantity,
      'price': price,
      'store': store, // Include store in the JSON
      'storeId': storeId, // Include store ID in the JSON
    };
  }
}

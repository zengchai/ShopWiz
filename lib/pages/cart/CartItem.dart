import 'package:cloud_firestore/cloud_firestore.dart';

class CartItem {
  final String pid;
  final String name;
  final String image;
  final int quantity;
  final double price;

  CartItem({
    required this.pid,
    required this.name,
    required this.image,
    required this.quantity,
    required this.price,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      pid: json['pid'],
      name: json['name'],
      image: json['image'],
      quantity: json['quantity'],
      price: json['price'],
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pid': pid,
      'name': name,
      'image': image,
      'quantity': quantity,
      'price': price,
    };
  }
}

import 'package:shopwiz/pages/cart/CartItem.dart';

class Cart {
  String userId;
  List<CartItem> items;

  Cart({
    required this.userId,
    required this.items,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      userId: json['userId'] ?? '', // Handle potential null value
      items: (json['items'] as List<dynamic>)
          .map((item) => CartItem.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

class Orders {
  final String orderId;
  final int totalQuantity;
  final double totalPrice;
  final String status;
  final List<Store> stores;

  Orders({
    required this.orderId,
    required this.totalQuantity,
    required this.totalPrice,
    required this.status,
    required this.stores,
  });
}

class Store {
  final String storeId;
  String status;
  final List<Item> items;

  Store({
    required this.storeId,
    required this.items,
    this.status = "Pending", // Default value for status
  });

  void update(String newStatus) {
    this.status = newStatus;
  }
}

class Item {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  Item({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });
}

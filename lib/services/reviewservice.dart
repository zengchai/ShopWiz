import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopwiz/models/order.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shopwiz/services/database.dart';

class Reviewservice {
  final String uid;

  Reviewservice({required this.uid});

  // Reference to the users collection
  final CollectionReference reviewCollection =
      FirebaseFirestore.instance.collection('reviews');
  final CollectionReference productCollection =
      FirebaseFirestore.instance.collection('products');
  final CollectionReference orderCollection =
      FirebaseFirestore.instance.collection('orders');

  Future updateReviewData(String productID, String orderID, String userID,
      String review, double rating, String userName) async {
    try {
      var docRef = await reviewCollection.add({
        'userID': uid,
        'orderID': orderID,
        'userName': userName,
        'rating': rating,
        'review': review,
      });

      String docId = docRef.id;
      await productCollection.doc(productID).update({
        'review': FieldValue.arrayUnion([docId]),
      });

      return null; // Return the document ID
    } catch (e) {
      print('Error adding review: $e');
      return null;
    }
  }

  Future<String?> getProductImageURL(String pid) async {
    try {
      if (pid == null || pid.isEmpty) {
        print("Invalid PID");
        return null; // Return null for invalid PID
      }

      Reference storageReference = FirebaseStorage.instance.ref().child(
          'ProductImages/$pid.jpg'); // Using product ID for the image path

      return await storageReference.getDownloadURL(); // Return the image URL
    } catch (e) {
      print('Error getting product image URL: $e');
      return null; // Return null on error
    }
  }

  Future<List<Orders>> getOrderData(String uid) async {
    try {
      final userData = await DatabaseService(uid: uid).getUserData();
      List<dynamic> userOrders = userData['order'] ?? [];
      List<Orders> ordersList = [];

      // Admin UID
      String adminUid = "7aXevcNf3Cahdmk9l5jLRASw5QO2";

      // Check if the user is admin
      if (uid == adminUid) {
        // Fetch all orders
        QuerySnapshot snapshot = await orderCollection.get();
        for (var doc in snapshot.docs) {
          Map<String, dynamic>? orderData = doc.data() as Map<String, dynamic>?;
          print(orderData);
          if (orderData != null) {
            ordersList.add(await _createOrderFromData(orderData));
          }
        }
      } else {
        // Fetch only user orders
        for (var orderId in userOrders) {
          DocumentSnapshot snapshot = await orderCollection.doc(orderId).get();
          Map<String, dynamic>? orderData =
              snapshot.data() as Map<String, dynamic>?;

          if (orderData != null) {
            ordersList.add(await _createOrderFromData(orderData));
          }
        }
      }

      return ordersList;
    } catch (e) {
      print("Error retrieving order data: $e");
      return [];
    }
  }

  Future<Orders> _createOrderFromData(Map<String, dynamic> orderData) async {
    List<Store> stores = [];
    var storeData = orderData['store'];

    if (storeData is List) {
      for (var store in storeData) {
        if (store is Map<String, dynamic>) {
          List<Item> items = [];
          var itemsData = store['items'];

          if (itemsData is List) {
            for (var item in itemsData) {
              if (item is Map<String, dynamic>) {
                items.add(Item(
                  productId: item['productId'],
                  productName: item['productName'],
                  quantity: item['quantity'],
                  price: item['price'].toDouble(),
                ));
              } else {
                print("Unexpected item type: ${item.runtimeType}");
              }
            }
          } else if (itemsData is Map<String, dynamic>) {
            items.add(Item(
              productId: itemsData['productId'],
              productName: itemsData['productName'],
              quantity: itemsData['quantity'],
              price: itemsData['price'].toDouble(),
            ));
          } else {
            print("Unexpected items data type: ${itemsData.runtimeType}");
          }

          stores.add(Store(
            storeId: store['storeId'],
            items: items,
          ));
        } else {
          print("Unexpected store item type: ${store.runtimeType}");
        }
      }
    } else {
      print("Unexpected store data type: ${storeData.runtimeType}");
    }

    return Orders(
      orderId: orderData['orderId'],
      totalQuantity: orderData['totalQuantity'],
      totalPrice: orderData['totalPrice'].toDouble(),
      status: orderData['status'],
      stores: stores,
    );
  }
}

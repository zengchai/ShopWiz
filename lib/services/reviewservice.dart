import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shopwiz/models/order.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shopwiz/models/review.dart';
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

  Future<bool> checkReview(
      String orderId, String storeId, String productId) async {
    try {
      DocumentSnapshot snapshot = await orderCollection.doc(orderId).get();
      Map<String, dynamic>? orderData =
          snapshot.data() as Map<String, dynamic>?;

      if (orderData != null) {
        List<dynamic> stores = orderData['store'] ?? [];

        // Find the specific store by its storeId
        for (var store in stores) {
          if (store['storeId'] == storeId) {
            List<dynamic> items = store['items'] ?? [];

            // Find the specific item by its productId
            for (var item in items) {
              if (item['productId'] == productId) {
                // Check if the reviews field is null
                return item['reviews'] == null;
              }
            }
          }
        }
      }
      return false; // Default to false if the order, store, or item is not found
    } catch (e) {
      print('Error checking review: $e');
      return false;
    }
  }

  Future<void> updateReviewData(
      String storeId,
      String productId,
      String orderId,
      String userId,
      String review,
      double rating,
      String userName) async {
    try {
      // Check if the item already has a review
      bool canAddReview = await checkReview(orderId, storeId, productId);

      if (canAddReview) {
        // Add the review to the review collection
        var docRef = await reviewCollection.add({
          'userID': userId,
          'orderID': orderId,
          'userName': userName,
          'rating': rating,
          'review': review,
        });

        String docId = docRef.id;

        // Update the product with the new review ID
        await productCollection.doc(productId).update({
          'review': FieldValue.arrayUnion([docId]),
        });

        // Fetch the order document
        DocumentSnapshot snapshot = await orderCollection.doc(orderId).get();
        Map<String, dynamic>? orderData =
            snapshot.data() as Map<String, dynamic>?;

        if (orderData != null) {
          List<dynamic> stores = orderData['store'] ?? [];

          // Find the specific store by its storeId
          for (var store in stores) {
            if (store['storeId'] == storeId) {
              List<dynamic> items = store['items'] ?? [];

              // Find the specific item by its productId
              for (var item in items) {
                if (item['productId'] == productId) {
                  // Add the review ID to the item
                  if (item['reviews'] == null) {
                    item['reviews'] = docId;
                  } else {
                    item['reviews'].add(docId);
                  }
                  break;
                }
              }
              break;
            }
          }

          // Update the order document with the modified store and item list
          await orderCollection.doc(orderId).update({
            'store': stores,
          });
        }
      } else {
        print('Review already exists for this item.');
      }
    } catch (e) {
      print('Error adding review: $e');
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

  Future<void> updateReviewStatus(String orderId, String storeId) async {
    try {
      // Fetch the order document
      DocumentSnapshot snapshot = await orderCollection.doc(orderId).get();
      Map<String, dynamic>? orderData =
          snapshot.data() as Map<String, dynamic>?;

      if (orderData != null) {
        List<dynamic> stores = orderData['store'] ?? [];

        // Find the specific store by its storeId and update the status
        for (var store in stores) {
          if (store['storeId'] == storeId) {
            store['status'] = 'Received';
            break;
          }
        }

        // Update the order document with the modified store list
        await orderCollection.doc(orderId).update({
          'store': stores,
        });
        // Check if all stores have the status 'Received'
        bool allStoresReceived =
            stores.every((store) => store['status'] == 'Received');

        // If all stores are 'Received', update the order status to 'Received'
        if (allStoresReceived) {
          await orderCollection.doc(orderId).update({
            'status': 'Received',
          });
        }
      }
    } catch (e) {
      print('Error updating review status: $e');
    }
  }

  Future<Map<String, int>> getMonthlyOrders(String year) async {
    Map<String, int> monthlyOrders = {};

    try {
      QuerySnapshot snapshot = await orderCollection
          .where('date',
              isGreaterThanOrEqualTo: DateTime(int.parse(year), 1, 1))
          .where('date', isLessThanOrEqualTo: DateTime(int.parse(year), 12, 31))
          .get();

      for (var doc in snapshot.docs) {
        Timestamp timestamp = doc['date'];
        DateTime date = timestamp.toDate();
        String monthKey = DateFormat('MMMM').format(date);

        if (monthlyOrders.containsKey(monthKey)) {
          monthlyOrders[monthKey] = monthlyOrders[monthKey]! + 1;
        } else {
          monthlyOrders[monthKey] = 1;
        }
      }
    } catch (e) {
      print("Error fetching monthly orders: $e");
    }

    return monthlyOrders;
  }

  Future<Map<String, dynamic>> getTodaysOrders() async {
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    QuerySnapshot ordersSnapshot = await orderCollection
        .where('date', isGreaterThanOrEqualTo: startOfDay)
        .where('date', isLessThanOrEqualTo: endOfDay)
        .get();

    int totalOrders = ordersSnapshot.docs.length;
    double totalPrice = 0.0;

    for (var doc in ordersSnapshot.docs) {
      totalPrice += doc[
          'totalPrice']; // Adjust the field name as per your Firestore schema
    }

    return {
      'totalOrders': totalOrders,
      'totalPrice': totalPrice,
    };
  }

  Future<List<Review>> getReviewsByProductId(String productId) async {
    try {
      // Fetch the product document
      DocumentSnapshot productSnapshot =
          await productCollection.doc(productId).get();

      if (productSnapshot.exists) {
        List<dynamic> reviewIds = productSnapshot['review'];
        print(reviewIds);
        // Fetch the reviews based on the reviewIds
        List<Review> reviews = [];
        for (String reviewId in reviewIds) {
          DocumentSnapshot reviewSnapshot =
              await reviewCollection.doc(reviewId).get();
          if (reviewSnapshot.exists) {
            reviews.add(Review.fromFirestore(reviewSnapshot));
          }
        }

        return reviews;
      } else {
        throw Exception("Product not found");
      }
    } catch (error) {
      print("Error fetching reviews: $error");
      throw error;
    }
  }
}

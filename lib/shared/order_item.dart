import 'package:flutter/material.dart';
import 'package:shopwiz/pages/order/order_detail.dart';
import 'package:shopwiz/pages/order/review_widget.dart';
import 'package:shopwiz/services/auth.dart';
import 'package:shopwiz/services/database.dart';
import 'package:shopwiz/services/reviewservice.dart';
import 'package:shopwiz/shared/image.dart';

class Order_item extends StatefulWidget {
  final String storeId;
  final String orderId;
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  const Order_item({
    Key? key,
    required this.storeId,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  }) : super(key: key);

  @override
  State<Order_item> createState() => _Order_itemState();
}

class _Order_itemState extends State<Order_item> {
  final AuthService _auth = AuthService();
  late Map<String, dynamic> userData = {};

  Future<void> addReview(BuildContext context) async {
    try {
      String uid = _auth.getCurrentUser().uid;
      userData = await DatabaseService(uid: uid).getUserData();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return ReviewPopup(
            uid: uid,
            storeId: widget.storeId,
            productId: widget.productId,
            productName: widget.productName,
            orderId: widget.orderId,
            userName: userData['username'],
          );
        },
      );
    } catch (e) {
      print(e);
    }
  }

  Future<bool> checkReview() async {
    try {
      String uid = _auth.getCurrentUser().uid;
      bool review = await Reviewservice(uid: uid)
          .checkReview(widget.orderId, widget.storeId, widget.productId);
      print(review);
      return review;
    } catch (e) {
      print(e);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    String uid = _auth.getCurrentUser().uid;
    return Row(
      children: [
        ProductImageWidget(productId: widget.productId),
        const SizedBox(width: 25),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.productName,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Opacity(
                        opacity: 0.7,
                        child: Text(
                          "Qty: ${widget.quantity}",
                          style: TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Opacity(
                        opacity: 0.7,
                        child: Text(
                          "RM ${widget.price}",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      uid == "7aXevcNf3Cahdmk9l5jLRASw5QO2"
                          ? Container()
                          : FutureBuilder<bool>(
                              future: checkReview(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                } else if (snapshot.hasError) {
                                  return ElevatedButton(
                                    onPressed: null,
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 2,
                                        horizontal: 15,
                                      ),
                                      backgroundColor: Colors.grey,
                                    ),
                                    child: Text(
                                      'Error',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                } else {
                                  bool reviewExists = snapshot.data ?? false;
                                  return ElevatedButton(
                                    onPressed: !reviewExists
                                        ? null
                                        : () {
                                            addReview(context);
                                          },
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 2,
                                        horizontal: 15,
                                      ),
                                      backgroundColor: !reviewExists
                                          ? Colors.grey
                                          : Color.fromARGB(
                                              255,
                                              108,
                                              74,
                                              255,
                                            ),
                                    ),
                                    child: Text(
                                      'Review',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                      SizedBox(height: 4),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shopwiz/pages/order/order_detail.dart';
import 'package:shopwiz/pages/order/review_widget.dart';
import 'package:shopwiz/services/auth.dart';
import 'package:shopwiz/services/database.dart';
import 'package:shopwiz/shared/image.dart';

class Order_item extends StatefulWidget {
  final String orderId;
  final String productId;
  final String productName;
  final int quantity;
  final double price;
  const Order_item(
      {Key? key,
      required this.orderId,
      required this.productId,
      required this.productName,
      required this.quantity,
      required this.price});

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
            productId: widget.productId,
            productName: widget.productName,
            orderId: widget.orderId,
            userName: userData['username'],
          ); // Pass uid to ReviewPopup
        },
      );
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                          "Qty: 2",
                          style: TextStyle(
                            fontSize: 10,
                          ),
                        ),
                      ),
                      SizedBox(height: 8),
                      Opacity(
                        opacity: 0.7,
                        child: Text(
                          "RM 100.00",
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
                      ElevatedButton(
                        onPressed: () {
                          addReview(context);
                        },
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            vertical: 2,
                            horizontal: 15,
                          ),
                          backgroundColor: Color.fromARGB(
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
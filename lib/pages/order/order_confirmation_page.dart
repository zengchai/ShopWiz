import 'package:flutter/material.dart';
import 'package:shopwiz/models/order.dart';
import 'package:shopwiz/services/auth.dart';
import 'package:shopwiz/services/reviewservice.dart';
import 'package:shopwiz/shared/order_item.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final String orderId;
  final String status;
  final List<Store> store;

  const OrderConfirmationScreen({
    Key? key,
    required this.orderId,
    required this.status,
    required this.store,
  }) : super(key: key);

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  Future<void> _updateOrderStatus(String orderId, String storeId) async {
    final AuthService _auth = AuthService();

    final uid = _auth.getCurrentUser().uid;
    final orderService = Reviewservice(uid: uid);
    await orderService.updateReviewStatus(orderId, storeId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.all(20),
          child: Image.asset(
            'assets/images/Top_logo.png', // Path to your shop logo
            height: 40.0, // Adjust the height as needed
          ),
        ),
      ),
      body: Container(
          padding: EdgeInsets.fromLTRB(20, 15.0, 20, 0.0),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.ideographic,
                      children: [
                        SizedBox(width: 8),
                        Text(
                          "Order",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                        SizedBox(width: 8),
                        Opacity(
                          opacity: 0.7,
                          child: Text(
                            widget.orderId,
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: widget.status == "Pick Up"
                          ? Colors.yellow
                          : Colors.green[300],
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: EdgeInsets.fromLTRB(9, 2, 9, 2),
                    child: Opacity(
                      opacity: 0.7,
                      child: Text(
                        widget.status,
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                // Wrap with Expanded
                child: ListView.builder(
                  itemCount: widget.store.length,
                  itemBuilder: (context, index) {
                    final store = widget.store[index];
                    return Card(
                      margin: const EdgeInsets.fromLTRB(10, 25, 10, 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 5,
                      shadowColor: Colors.grey.withOpacity(0.0),
                      child: Container(
                        padding: EdgeInsets.fromLTRB(23, 15, 23, 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(
                                  0.3), // Set the shadow color and opacity
                              spreadRadius: 5, // Spread radius
                              blurRadius: 10, // Blur radius
                              offset:
                                  Offset(0, 0), // Offset in x and y direction
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(store.storeId),
                                ElevatedButton(
                                  onPressed: () {
                                    if (widget.status == "Pick Up") {
                                      if (store.status != "Received") {
                                        _updateOrderStatus(
                                            widget.orderId, store.storeId);
                                        setState(() {
                                          store.update("Received");
                                        });
                                      }
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 2,
                                      horizontal: 15,
                                    ),
                                    backgroundColor:
                                        widget.status == "Received" &&
                                                store.status != null
                                            ? Colors.grey[300]
                                            : Color.fromARGB(
                                                255,
                                                108,
                                                74,
                                                255,
                                              ),
                                  ),
                                  child: Text(
                                    'Complete',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: store.items.length,
                              itemBuilder: (context, itemIndex) {
                                final item = store.items[itemIndex];
                                return Column(
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Order_item(
                                      orderId: widget.orderId,
                                      productId: item.productId,
                                      productName: item.productName,
                                      quantity: item.quantity,
                                      price: item.price.toDouble(),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              )
            ],
          )),
    );
  }
}

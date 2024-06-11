import 'package:flutter/material.dart';
import 'package:shopwiz/commons/BaseLayout.dart';
import 'package:shopwiz/commons/BaselayoutAdmin.dart';
import 'package:shopwiz/models/order.dart';
import 'package:shopwiz/services/auth.dart';
import 'package:shopwiz/services/database.dart';
import 'package:shopwiz/services/reviewservice.dart';
import 'package:shopwiz/shared/order_card.dart';
import 'package:shopwiz/shared/order_confirmation_card.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final AuthService _auth = AuthService();
  List<Orders> orderDataList = [];
  List<Orders> ongoingOrders = [];
  List<Orders> historyOrders = [];
  @override
  void initState() {
    super.initState();
    _fetchOrderData();
  }

  Future<void> _fetchOrderData() async {
    final uid = _auth.getCurrentUser().uid;
    final orderService = Reviewservice(uid: uid);
    try {
      final orderList = await orderService.getOrderData(uid);
      setState(() {
        orderDataList = orderList;
      });
      _filterOrders();
    } catch (e) {
      print("Error fetching order data: $e");
    }
  }

  void _filterOrders() {
    setState(() {
      ongoingOrders =
          orderDataList.where((order) => order.status == 'Pick Up').toList();
      print(ongoingOrders);
      historyOrders =
          orderDataList.where((order) => order.status == 'Received').toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = _auth.getCurrentUser().uid;
    return uid == "7aXevcNf3Cahdmk9l5jLRASw5QO2"
        ? BaseLayoutAdmin(
            child: DefaultTabController(
              length: 2,
              initialIndex: 0,
              child: Scaffold(
                appBar: TabBar(
                  tabs: [
                    Tab(text: "Ongoing"),
                    Tab(text: "History"),
                  ],
                ),
                body: TabBarView(
                  children: [
                    // Ongoing tab content
                    ListView.builder(
                      itemCount: ongoingOrders.length,
                      itemBuilder: (context, index) {
                        // Retrieve order data for this index
                        final orderData = ongoingOrders[index];
                        // Build and return Order_card widget
                        return Order_Confirmation_Card(
                          orderId: orderData.orderId,
                          totalQuantity: orderData.totalQuantity,
                          totalPrice: orderData.totalPrice,
                          status: orderData.status,
                          store: orderData.stores,
                        );
                      },
                    ),
                    // History tab content
                    ListView.builder(
                      itemCount: historyOrders.length,
                      itemBuilder: (context, index) {
                        // Retrieve order data for this index
                        final orderData = historyOrders[index];
                        // Build and return Order_card widget
                        return Order_Confirmation_Card(
                          orderId: orderData.orderId,
                          totalQuantity: orderData.totalQuantity,
                          totalPrice: orderData.totalPrice,
                          status: orderData.status,
                          store: orderData.stores,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          )
        : BaseLayout(
            child: DefaultTabController(
              length: 2,
              initialIndex: 0,
              child: Scaffold(
                appBar: TabBar(
                  tabs: [
                    Tab(text: "Ongoing"),
                    Tab(text: "History"),
                  ],
                ),
                body: TabBarView(
                  children: [
                    // Ongoing tab content
                    ListView.builder(
                      itemCount: ongoingOrders.length,
                      itemBuilder: (context, index) {
                        // Retrieve order data for this index
                        final orderData = ongoingOrders[index];
                        // Build and return Order_card widget
                        return uid == "7aXevcNf3Cahdmk9l5jLRASw5QO2"
                            ? Order_Confirmation_Card(
                                orderId: orderData.orderId,
                                totalQuantity: orderData.totalQuantity,
                                totalPrice: orderData.totalPrice,
                                status: orderData.status,
                                store: orderData.stores,
                              )
                            : Order_card(
                                orderId: orderData.orderId,
                                totalQuantity: orderData.totalQuantity,
                                totalPrice: orderData.totalPrice,
                                status: orderData.status,
                                store: orderData.stores,
                              );
                      },
                    ),
                    // History tab content
                    ListView.builder(
                      itemCount: historyOrders.length,
                      itemBuilder: (context, index) {
                        // Retrieve order data for this index
                        final orderData = historyOrders[index];
                        // Build and return Order_card widget
                        return uid == "7aXevcNf3Cahdmk9l5jLRASw5QO2"
                            ? Order_Confirmation_Card(
                                orderId: orderData.orderId,
                                totalQuantity: orderData.totalQuantity,
                                totalPrice: orderData.totalPrice,
                                status: orderData.status,
                                store: orderData.stores,
                              )
                            : Order_card(
                                orderId: orderData.orderId,
                                totalQuantity: orderData.totalQuantity,
                                totalPrice: orderData.totalPrice,
                                status: orderData.status,
                                store: orderData.stores,
                              );
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}

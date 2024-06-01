import 'package:flutter/material.dart';
import 'package:shopwiz/commons/BaseLayout.dart';
import 'package:shopwiz/models/order.dart';
import 'package:shopwiz/services/auth.dart';
import 'package:shopwiz/services/database.dart';
import 'package:shopwiz/services/reviewservice.dart';
import 'package:shopwiz/shared/order_card.dart';

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
    ongoingOrders =
        orderDataList.where((order) => order.status == 'Pick Up').toList();
    historyOrders =
        orderDataList.where((order) => order.status == 'Received').toList();
  }
  // // Sample list of order data retrieved from the database
  // final List<Map<String, dynamic>> orderDatasList = [
  //   {
  //     "orderId": "23",
  //     "totalQuantity": 3,
  //     "totalPrice": 50.00,
  //     "status": "Pick Up",
  //     "store": [
  //       {
  //         "storeName": "123",
  //         "items": [
  //           {
  //             "productId": "oUgIj0ESgWiGpKw5OMHz",
  //             "productName": "Vitamin C",
  //             "quantity": 1,
  //             "price": 20.00
  //           },
  //           {
  //             "productId": "DaE21xjHrkI6lsNqkOtD",
  //             "productName": "plast",
  //             "quantity": 2,
  //             "price": 30.00
  //           },
  //         ],
  //       },
  //       {
  //         "storeName": "456",
  //         "items": [
  //           {
  //             "productId": "oUgIj0ESgWiGpKw5OMHz",
  //             "productName": "Vitamin C",
  //             "quantity": 1,
  //             "price": 20.00
  //           },
  //           {
  //             "productId": "DaE21xjHrkI6lsNqkOtD",
  //             "productName": "plast",
  //             "quantity": 2,
  //             "price": 30.00
  //           },
  //         ],
  //       }
  //     ]
  //   },
  //   {
  //     "orderId": "1",
  //     "totalQuantity": 3,
  //     "totalPrice": 50.00,
  //     "status": "Pick Up",
  //     "store": [
  //       {
  //         "storeName": "123",
  //         "items": [
  //           {
  //             "productId": "csyldbqCBq1Bu7yzkUBD",
  //             "productName": "Vitamin C",
  //             "quantity": 1,
  //             "price": 20.00
  //           },
  //           {
  //             "productId": "XnCbdKlLMook7smUVDb9",
  //             "productName": "Gauze",
  //             "quantity": 2,
  //             "price": 30.00
  //           },
  //         ],
  //       }
  //     ]
  //   },
  // ];

  @override
  Widget build(BuildContext context) {
    final uid = _auth.getCurrentUser().uid;
    return BaseLayout(
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
                  return uid == ""
                      ? Order_card(
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
                  return Order_card(
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

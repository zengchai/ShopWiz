import 'package:flutter/material.dart';
import 'package:shopwiz/commons/BaseLayout.dart';
import 'package:shopwiz/shared/order_card.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  // Sample list of order data retrieved from the database
  final List<Map<String, dynamic>> orderDataList = [
    {
      "orderId": "23",
      "totalQuantity": 3,
      "totalPrice": 50.00,
      "status": "Pick Up",
      "store": [
        {
          "storeName": "123",
          "items": [
            {
              "productId": "oUgIj0ESgWiGpKw5OMHz",
              "productName": "Product 1",
              "quantity": 1,
              "price": 20.00
            },
            {
              "productId": "DaE21xjHrkI6lsNqkOtD",
              "productName": "Product 2",
              "quantity": 2,
              "price": 30.00
            },
          ],
        },
        {
          "storeName": "456",
          "items": [
            {
              "productId": "oUgIj0ESgWiGpKw5OMHz",
              "productName": "Product 1",
              "quantity": 1,
              "price": 20.00
            },
            {
              "productId": "DaE21xjHrkI6lsNqkOtD",
              "productName": "Product 2",
              "quantity": 2,
              "price": 30.00
            },
          ],
        }
      ]
    },
    {
      "orderId": "1",
      "totalQuantity": 3,
      "totalPrice": 50.00,
      "status": "Pick Up",
      "store": [
        {
          "storeName": "123",
          "items": [
            {
              "productId": "csyldbqCBq1Bu7yzkUBD",
              "productName": "Product 1",
              "quantity": 1,
              "price": 20.00
            },
            {
              "productId": "XnCbdKlLMook7smUVDb9",
              "productName": "Product 2",
              "quantity": 2,
              "price": 30.00
            },
          ],
        }
      ]
    },
  ];

  @override
  Widget build(BuildContext context) {
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
                itemCount: orderDataList.length,
                itemBuilder: (context, index) {
                  // Retrieve order data for this index
                  final orderData = orderDataList[index];
                  // Build and return Order_card widget
                  return Order_card(
                    orderId: orderData['orderId'],
                    totalQuantity: orderData['totalQuantity'],
                    totalPrice: orderData['totalPrice'],
                    status: orderData['status'],
                    store: orderData['store'],
                  );
                },
              ),
              // History tab content
              Center(child: Text("Tab 2 content")),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shopwiz/commons/BaseLayout.dart';
import 'package:shopwiz/commons/BaselayoutAdmin.dart';
import 'package:shopwiz/pages/home/model/product.dart';
import 'package:shopwiz/pages/home/productdetails.dart';

import 'package:shopwiz/services/firebase_service.dart'; // Import the FirebaseService

class HomeScreen extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    String adminUid = '7aXevcNf3Cahdmk9l5jLRASw5QO2';
    String currentUid = FirebaseAuth.instance.currentUser?.uid ?? '';

    return currentUid == adminUid
        ? BaseLayoutAdmin(
            child: Center(
              child: Text(
                'Home Screen - Admin',
                style: TextStyle(fontSize: 24.0),
              ),
            ),
          )
        : BaseLayout(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Discover',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.green[900],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<Product>>(
                    future: _firebaseService
                        .getProducts(), // Fetch products from Firebase
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else {
                        List<Product> products = snapshot.data!;
                        return ListView.builder(
                          itemCount: (products.length / 2).ceil(),
                          itemBuilder: (context, index) {
                            final startIndex = index * 2;
                            final endIndex = startIndex + 2;
                            return Row(
                              children: [
                                for (int i = startIndex; i < endIndex; i++)
                                  if (i < products.length)
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: _buildCard(context, products[i]),
                                      ),
                                    ),
                              ],
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          );
  }

  Widget _buildCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsScreen(
              productId: product.pid,
              userId: '',
            ),
          ),
        );
      },
      child: Card(
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            SizedBox(
              width: double.infinity,
              height: 200, // Increase the height of the card
              child: Image.network(
                product.pimageUrl,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  Text(
                    product.pname,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.0),
                  // Product price
                  Text(
                    '\RM ${product.pprice.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green[900],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

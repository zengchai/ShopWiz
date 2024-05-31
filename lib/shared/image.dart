import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:shopwiz/services/auth.dart';
import 'package:shopwiz/services/database.dart';

class ProductImageWidget extends StatefulWidget {
  final String productId;

  const ProductImageWidget({Key? key, required this.productId})
      : super(key: key);

  @override
  _ProductImageWidgetState createState() => _ProductImageWidgetState();
}

class _ProductImageWidgetState extends State<ProductImageWidget> {
  final AuthService _auth = AuthService();

  String? imageURL;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    String uid = _auth.getCurrentUser().uid;
    String? url =
        await DatabaseService(uid: uid).getProductImageURL(widget.productId);
    setState(() {
      imageURL = url;
    });
  }

  @override
  Widget build(BuildContext context) {
    return imageURL != null
        ? Image.network(
            imageURL!, width: 100, // Adjust the width as needed
            height: 100,
          ) // Display the image using Image.network widget
        : CircularProgressIndicator(); // Show a loading indicator while image is being fetched
  }
}
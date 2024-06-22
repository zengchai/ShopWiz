import 'package:flutter/material.dart';
import 'package:shopwiz/services/auth.dart';
import 'package:shopwiz/services/reviewservice.dart';

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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    try {
      String uid = _auth.getCurrentUser().uid;
      String? url =
          await Reviewservice(uid: uid).getProductImageURL(widget.productId);
      if (mounted) {
        setState(() {
          imageURL = url;
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Error loading image: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // Here you can cancel any subscriptions or ongoing operations
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? CircularProgressIndicator() // Show a loading indicator while the image is being fetched
        : imageURL != null
            ? Image.network(
                imageURL!,
                width: 100, // Adjust the width as needed
                height: 100,
              ) // Display the image using Image.network widget
            : Icon(Icons.error); // Show an error icon if the image URL is null
  }
}
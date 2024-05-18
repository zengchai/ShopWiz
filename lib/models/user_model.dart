import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shopwiz/pages/cart/CartItem.dart';

class User {
  final String uid;
  final String username;
  final String email;
  final String phonenum;
  final String imageUrl; 

  User({
    required this.uid,
    required this.username,
    required this.email,
    required this.phonenum,
    required this.imageUrl,
  });

}
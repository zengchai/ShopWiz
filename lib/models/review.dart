import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String uid;
  final String orderID;
  final String userName;
  final double rating;
  final String review;

  Review({
    required this.uid,
    required this.orderID,
    required this.userName,
    required this.rating,
    required this.review,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Review(
      uid: data['userId'] ?? '',
      orderID: data['orderID'] ?? '',
      userName: data['userName'] ?? 'Anonymous',
      review: data['review'] ?? '',
      rating: data['rating'] ?? 0,
    );
  }
}

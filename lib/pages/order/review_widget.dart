import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:shopwiz/services/database.dart';
import 'package:shopwiz/shared/image.dart'; // Assuming you have a DatabaseService class defined

class ReviewPopup extends StatefulWidget {
  final String uid;
  final String productId;
  final String orderId;
  final String productName;
  final String userName;

  const ReviewPopup(
      {required this.uid,
      required this.productId,
      required this.productName,
      required this.orderId,
      required this.userName});

  @override
  State<ReviewPopup> createState() => _ReviewPopupState();
}

class _ReviewPopupState extends State<ReviewPopup> {
  final _formKey = GlobalKey<FormState>();
  String review = '';
  double rating = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero, // Remove default padding

      content: SingleChildScrollView(
          child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Set background color here
          borderRadius: BorderRadius.circular(20), // Set border radius here
        ),
        padding: EdgeInsets.all(20),
        child: ListBody(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Review",
                    style: TextStyle(
                      fontSize: 20,
                    )),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    child: Icon(
                      Icons.cancel,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              children: [
                ProductImageWidget(productId: widget.productId),
                SizedBox(
                  width: 5,
                ),
                Column(
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
                    Opacity(
                      opacity: 0.7,
                      child: Text(
                        widget.orderId,
                        style: TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
            SizedBox(height: 10),
            RatingBar.builder(
              initialRating: rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemSize: 30.0,
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (newRating) {
                setState(() {
                  rating = newRating;
                });
              },
            ),
            SizedBox(height: 15),
            Form(
              key: _formKey,
              child: TextFormField(
                decoration: InputDecoration(
                  labelText: 'Enter review here',
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val!.isEmpty ? 'Enter review' : null,
                onChanged: (value) {
                  setState(() {
                    review = value;
                  });
                },
              ),
            ),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      await DatabaseService(uid: widget.uid).updateReviewData(
                        widget.productId,
                        widget.orderId,
                        widget.uid,
                        review,
                        rating,
                        widget.userName,
                      );
                      Navigator.of(context).pop();
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Color.fromARGB(
                        255,
                        108,
                        74,
                        255,
                      ),
                    ),
                  ),
                  child: Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      )),
    );
  }
}
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String email = '';
  bool isLoading = false;

  void resetPassword() async {
    setState(() {
      isLoading = true;
    });

    // Email format validation
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid email address.'),
        ),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Password reset email sent. Please check your email.'),
        ),
      );

      // Navigate back to the sign-in page
      Navigator.pop(context);
    } catch (e) {
      print('Error sending password reset email: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Error sending password reset email. Please try again later.'),
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.0, 50.0, 16.0, 0.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40.0),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: Text(
                    'Enter your email to reset your password',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Container(
                width: 350.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      onChanged: (value) {
                        setState(() {
                          email = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 350.0,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : () => resetPassword(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 108, 74, 255),
                      ),
                      child: isLoading
                          ? CircularProgressIndicator()
                          : Text(
                              'Confirm',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

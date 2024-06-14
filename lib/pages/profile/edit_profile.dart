import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shopwiz/services/auth.dart';
import 'package:shopwiz/services/database.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final AuthService _auth = AuthService();
  late Map<String, dynamic> userData = {};
  final DatabaseService _db = DatabaseService(uid: '');
  late Future<Map<String, dynamic>> _userDataFuture =
      {} as Future<Map<String, dynamic>>;

  late String newUsername = "";
  late String newPhoneNumber = "";
  late String newPassword = "";
  late String confirmPassword = "";
  late TextEditingController usernameController = TextEditingController();
  late TextEditingController phoneNumberController = TextEditingController();
  late TextEditingController newPasswordController = TextEditingController();
  late TextEditingController confirmPasswordController =
      TextEditingController();
  bool isSavingChanges = false;
  File? _image = null;
  ImagePicker picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _userDataFuture = loadData();
  }

  Future<Map<String, dynamic>> loadData() async {
    String uid = _auth.getCurrentUser().uid;
    userData = await DatabaseService(uid: uid).getUserData();
    print("User Data: $userData"); // Add this line to check the userData
    setState(() {
      this.userData = userData;
      newUsername = userData['username'] ?? 'Anonymous';
      newPhoneNumber = userData['phonenum'] ?? 'No Phone Number';
      newPassword = '';
      confirmPassword = '';
      usernameController = TextEditingController(text: newUsername);
      phoneNumberController = TextEditingController(text: newPhoneNumber);
      newPasswordController = TextEditingController(text: newPassword);
      confirmPasswordController = TextEditingController(text: confirmPassword);
    });
    return userData;
  }

  Future<void> _getImageGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        print('Image: $_image');
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _getImageCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
        print('Image: $_image');
      } else {
        print('No image selected.');
      }
    });
  }

  void saveChanges() async {
    if (newPassword != '' && confirmPassword != '') {
      if (newPassword.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password must be at least 6 characters'),
          ),
        );
        return;
      }
    }

    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Passwords do not match'),
        ),
      );
      return;
    }

    // Get the current user
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String uid = user.uid;
      String? imageUrl;
      try {
        if (newPassword != "") {
          if (_image != null) {
            // Update the user's document with the image URL
            imageUrl = await _db.uploadProfileImage(_image!, uid);
            await _db.updateUserData(uid, usernameController.text,
                phoneNumberController.text, imageUrl ?? userData['imageUrl']);
            print('Profile updated successfully');
            await user.updatePassword(newPassword);
          } else {
            await _db.updateUserData(uid, usernameController.text,
                phoneNumberController.text, imageUrl ?? userData['imageUrl']);
            print('Profile updated successfully');
            await user.updatePassword(newPassword);
          }
        } else {
          if (_image != null) {
            // Update the user's document with the image URL
            imageUrl = await _db.uploadProfileImage(_image!, uid);
            await _db.updateUserData(uid, usernameController.text,
                phoneNumberController.text, imageUrl ?? userData['imageUrl']);
            print('Profile updated successfully');
          } else {
            await _db.updateUserData(uid, usernameController.text,
                phoneNumberController.text, imageUrl ?? userData['imageUrl']);
            print('Profile updated successfully');
          }
        }

        // Update the state with the new information
        setState(() {
          newUsername = usernameController.text;
          usernameController.text = newUsername;
          newPhoneNumber = phoneNumberController.text;
          phoneNumberController.text = newPhoneNumber;
          newPassword = '';
          confirmPassword = '';
          imageUrl = imageUrl ?? userData['imageUrl'];
        });

        print('New Username: $newUsername');
        print('New Phone Number: $newPhoneNumber');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Profile updated successfully'),
          ),
        );

        // Pass the updated data back to the profile screen
        Navigator.pop(context, {
          'username': newUsername,
          'phonenum': newPhoneNumber,
          'imageUrl': imageUrl
        });

        setState(() {
          isSavingChanges = true;
        });
      } catch (e) {
        // Handle any errors
        print('Error updating profile: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile'),
          ),
        );
        setState(() {
          isSavingChanges = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: EdgeInsets.all(26),
          child: Image.asset(
            'assets/images/Top_logo.png', // Path to your shop logo
            height: 40.0, // Adjust the height as needed
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          // Once data is loaded, update the UI
          Map<String, dynamic> userData = snapshot.data!;
          newUsername = userData['username'] ?? 'Anonymous';
          newPhoneNumber = userData['phonenum'] ?? 'No Phone Number';
          usernameController = TextEditingController(text: newUsername);
          phoneNumberController = TextEditingController(text: newPhoneNumber);

          return SingleChildScrollView(
            child: Center(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.0, 15.0, 16.0, 0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: Text(
                          'Edit Profile',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30.0),
                    InkWell(
                      onTap: () {
                        _getImageGallery(); // Open gallery to select image
                        // or _getImage(ImageSource.camera); // Open camera to take a picture
                      },
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 70.0,
                            backgroundImage: _image != null
                                ? FileImage(
                                    _image!) // Show the newly uploaded image if available
                                : userData['imageUrl'] != null
                                    ? NetworkImage(userData['imageUrl'])
                                        as ImageProvider // Show the uploaded image if available
                                    : AssetImage(
                                        'assets/images/default_profile_image.jpg'), // Show the default image if no image is available // Use the imageUrl to show the profile image
                          ),
                          Positioned(
                            bottom: 0,
                            right: -5,
                            child: Icon(
                              Icons.edit,
                              color: Color.fromARGB(255, 108, 74, 255),
                              size: 30.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30.0),
                    Container(
                      width: 350.0,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Username'),
                          TextField(
                            readOnly: false,
                            controller: usernameController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.0),
                          Text('Phone Number'),
                          TextField(
                            readOnly: false,
                            controller: phoneNumberController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                          SizedBox(height: 16.0),
                          Text('New Password'),
                          TextField(
                            controller: newPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              newPassword = value;
                            },
                          ),
                          SizedBox(height: 16.0),
                          Text('Confirm Password'),
                          TextField(
                            controller: confirmPasswordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              confirmPassword = value;
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 30.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 350.0,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: saveChanges,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color.fromARGB(255, 108, 74, 255),
                            ),
                            child: isSavingChanges
                                ? CircularProgressIndicator()
                                : Text(
                                    'Save Changes',
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
        },
      ),
    );
  }
}

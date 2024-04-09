import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopwiz/commons/NavigationProvider.dart';
import 'package:shopwiz/commons/navBar.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  String newUsername = '';
  String newEmail = '';
  String newPassword = '';
  String newPhoneNumber = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //automaticallyImplyLeading: false, // Remove the back button
        title: Padding(
          padding: EdgeInsets.all(48),
          child: Image.asset(
            'assets/images/Top_logo.png', // Path to your shop logo
            height: 40.0, // Adjust the height as needed
          ),
        ),
      ),
      body: SingleChildScrollView(
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
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SizedBox(height: 30.0),
                Center(
                  child: CircleAvatar(
                    radius: 50.0,
                    backgroundImage:
                        AssetImage('assets/images/profile_pic.jpg'),
                  ),
                ),
                SizedBox(height: 30.0),
                Container(
                  width: 350.0,
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('New Username'),
                        Container(
                          width: 350.0,
                          child: TextFormField(
                            onChanged: (value) {
                              setState(() {
                                newUsername = value;
                              });
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        Text('New Email'),
                        Container(
                          width: 350.0,
                          child: TextFormField(
                            onChanged: (value) {
                              setState(() {
                                newEmail = value;
                              });
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        Text('New Phone Number'),
                        Container(
                          width: 350.0,
                          child: TextFormField(
                            onChanged: (value) {
                              setState(() {
                                newPhoneNumber = value;
                              });
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        Text('New Password'),
                        Container(
                          width: 350.0,
                          child: TextFormField(
                            onChanged: (value) {
                              setState(() {
                                newPassword = value;
                              });
                            },
                            obscureText: true,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                            ),
                          ),
                        ),
                      ]),
                ),
                SizedBox(height: 30.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 350.0,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          // Add logic to save the new profile information
                          // For demonstration purposes, just print the new values
                          print('New Username: $newUsername');
                          print('New Email: $newEmail');
                          print('New Password: $newPassword');
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Color.fromARGB(255, 108, 74, 255),
                        ),
                        child: Text(
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
      ),
      //Navigation Bar ============================
      bottomNavigationBar: Consumer<BottomNavigationBarModel>(
        builder: (context, model, _) => CustomBottomNavigationBar(
          selectedIndex: model.selectedIndex,
          onItemTapped: (index) {
            model.updateSelectedIndex(index);
          },
        ),
      ),
    );
  }
}

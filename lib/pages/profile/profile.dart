import 'package:flutter/material.dart';
import 'package:shopwiz/commons/BaseLayout.dart';
import 'package:shopwiz/pages/profile/edit_profile.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void editProfile() {
    // Navigate to edit profile screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BaseLayout(
      child: SingleChildScrollView(
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
                      'Profile',
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
                      Text('Username'),
                      Container(
                        width: 350.0,
                        child: TextFormField(
                          readOnly: true,
                          initialValue: 'JohnDoe123',
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text('Email'),
                      Container(
                        width: 350.0,
                        child: TextFormField(
                          readOnly: true,
                          initialValue: 'johndoe@example.com',
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text('Phone Number'),
                      Container(
                        width: 350.0,
                        child: TextFormField(
                          readOnly: true,
                          initialValue: '0107981891',
                          decoration: InputDecoration(
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                    ],
                  ),
                ),
                SizedBox(height: 20.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 350.0,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: editProfile,
                        style: ElevatedButton.styleFrom(
                          primary: Color.fromARGB(255, 108, 74, 255),
                        ),
                        child: Text(
                          'Edit Profile',
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
    );
  }
}

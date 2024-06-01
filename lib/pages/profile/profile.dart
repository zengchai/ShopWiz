import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopwiz/commons/BaseLayout.dart';
import 'package:shopwiz/commons/BaselayoutAdmin.dart';
import 'package:shopwiz/commons/NavigationProvider.dart';
import 'package:shopwiz/pages/authenticate/authenticate.dart';
import 'package:shopwiz/pages/profile/edit_profile.dart';
import 'package:shopwiz/services/auth.dart';
import 'package:shopwiz/services/database.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _auth = AuthService();
  late Future<Map<String, dynamic>> _userDataFuture =
      {} as Future<Map<String, dynamic>>;
  late Map<String, dynamic> userData = {};

  @override
  void initState() {
    super.initState();
    _userDataFuture = loadData();
  }

  Future<Map<String, dynamic>> loadData() async {
    String uid = _auth.getCurrentUser().uid;
    userData = await DatabaseService(uid: uid).getUserData();
    print("User Data: $userData"); // Add this line to check the userData
    if (mounted) {
      setState(() {
        this.userData = userData;
      });
    }
    return userData;
  }

  Future<void> editProfile() async {
    // Navigate to edit profile screen
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfileScreen()),
    );

    if (result != null) {
      setState(() {
        _userDataFuture = loadData();
      });
    }
  }

  void signOut() async {
    await _auth.signOut();
    Provider.of<CustomAuthProvider>(context, listen: false).signOut();
    // Navigation Bar ============================
    // Reset the selected index to 0
    Provider.of<BottomNavigationBarModel>(context, listen: false)
        .updateSelectedIndex(0);
    Navigator.pushReplacementNamed(context, '/sign_in');
  }

  void deleteProfilefunc() async {
    AuthService authService = AuthService();
    DatabaseService databaseService =
        DatabaseService(uid: authService.getCurrentUser().uid);

    Provider.of<CustomAuthProvider>(context, listen: false).signOut();
    // Navigation Bar ============================
    // Reset the selected index to 0
    Provider.of<BottomNavigationBarModel>(context, listen: false)
        .updateSelectedIndex(0);
    ;
    await _auth.deleteUser();
    await databaseService.deleteUserData();
    Navigator.pushReplacementNamed(context, '/sign_in');
  }

  void deleteProfile(BuildContext context) async {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete your profile?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                AuthService authService = AuthService();
                DatabaseService databaseService =
                    DatabaseService(uid: authService.getCurrentUser().uid);

                Provider.of<CustomAuthProvider>(context, listen: false)
                    .signOut();
                // Navigation Bar ============================
                // Reset the selected index to 0
                Provider.of<BottomNavigationBarModel>(context, listen: false)
                    .updateSelectedIndex(0);
                ;
                // Delete user data from Firestore
                await databaseService.deleteUserData();

                // Delete user account from Firebase Auth
                await authService.deleteUser();
                Navigator.pushReplacementNamed(context, '/sign_in');
              },
              child: Text('Confirm'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _userDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          final userData = snapshot.data!;
          bool isAdmin = userData['uid'] == '7aXevcNf3Cahdmk9l5jLRASw5QO2';

          return isAdmin ? adminLayout(userData) : customerLayout(userData);
        }
      },
    );
  }

  //admin profile
  Widget adminLayout(Map<String, dynamic> userData) {
    return BaseLayoutAdmin(
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
                    radius: 70.0,
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
                      TextField(
                        readOnly: true,
                        controller: TextEditingController(
                            text: userData['username'] ?? ''),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text('Email'),
                      TextField(
                        readOnly: true,
                        controller: TextEditingController(
                            text: userData['email'] ?? ''),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      SizedBox(height: 16.0),
                    ],
                  ),
                ),
                SizedBox(height: 100.0),
                Container(
                  width: 150.0,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: signOut,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text(
                      'Sign Out',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

//customer profile
  Widget customerLayout(Map<String, dynamic> userData) {
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
                    radius: 70.0,
                    backgroundImage: userData['imageUrl'] != null
                        ? NetworkImage(userData['imageUrl']) as ImageProvider
                        : AssetImage('assets/images/default_profile_image.jpg'),
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
                        readOnly: true,
                        controller: TextEditingController(
                            text: userData['username'] ?? ''),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text('Email'),
                      TextField(
                        readOnly: true,
                        controller: TextEditingController(
                            text: userData['email'] ?? ''),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Text('Phone Number'),
                      TextField(
                        readOnly: true,
                        controller: TextEditingController(
                            text: userData['phonenum'] ?? ''),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
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
                      width: 150.0,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: editProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 108, 74, 255),
                        ),
                        child: Text(
                          'Edit Profile',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Container(
                      width: 150.0,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () => deleteProfile(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: Text(
                          'Delete Account',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 320.0,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: signOut,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color.fromARGB(255, 122, 122, 122),
                        ),
                        child: Text(
                          'Sign Out',
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

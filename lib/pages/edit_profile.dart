import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:shareit/models/user.dart';
import 'package:shareit/pages/home.dart';
import 'package:shareit/widgets/progress.dart';

class EditProfile extends StatefulWidget {
  final String currentUserId;
  EditProfile({this.currentUserId});
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool isLoading = false;
  User user;
  String displayName = '', bio = '';
  bool flagName = true;
  bool flagBio = true;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController displayNameController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  @override
  void initState() {
    super.initState();
    getUser();
  }

  getUser() async {
    setState(() {
      isLoading = true;
    });
    DocumentSnapshot doc = await usersRef.document(widget.currentUserId).get();
    user = User.fromDocument(doc);
    bioController.text = user.bio;
    displayNameController.text = user.displayName;
    setState(() {
      isLoading = false;
    });
  }

  submit() {
    if (flagName && flagBio) {
      usersRef.document(widget.currentUserId).updateData({
        'displayName': displayNameController.text,
        'bio': bioController.text,
      });
      SnackBar snackBar = SnackBar(
        content: Text('Profile Updated!'),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
    }
  }

  logout() async {
    await googleSignIn.signOut();
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Home();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color(0xff424242),
        title: Text(
          'Edit Profile',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.done,
              color: Colors.green,
              size: 30,
            ),
          ),
        ],
      ),
      body: isLoading
          ? circularProgress()
          : ListView(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 30,
                      ),
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Color(0xFF424242),
                        backgroundImage: NetworkImage(user.photoUrl),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Form(
                        child: TextFormField(
                          controller: displayNameController,
                          onChanged: (values) {
                            displayName = values;
                            if (displayName.length < 3) {
                              setState(() {
                                flagName = false;
                              });
                            } else {
                              setState(() {
                                flagName = true;
                              });
                            }
                          },
                          decoration: InputDecoration(
                              suffixIcon: flagName
                                  ? Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    )
                                  : Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                    ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                borderSide: BorderSide(
                                  color: CupertinoDynamicColor.withBrightness(
                                    color: Color(0x33000000),
                                    darkColor: Color(0x33FFFFFF),
                                  ),
                                  style: BorderStyle.solid,
                                  width: 0.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                borderSide: BorderSide(
                                  color: CupertinoDynamicColor.withBrightness(
                                    color: Color(0x33000000),
                                    darkColor: Color(0x33FFFFFF),
                                  ),
                                  style: BorderStyle.solid,
                                  width: 0.0,
                                ),
                              ),
                              labelText: "Display Name",
                              //focusColor: Color(0xff424242),
                              labelStyle: TextStyle(fontSize: 15.0),
                              hintText: "Must be at least 3 character"),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Form(
                        child: TextFormField(
                          controller: bioController,
                          onChanged: (values) {
                            bio = values;
                            if (bio.length > 50) {
                              setState(() {
                                flagBio = false;
                              });
                            } else {
                              setState(() {
                                flagBio = true;
                              });
                            }
                          },
                          decoration: InputDecoration(
                              suffixIcon: flagBio
                                  ? Icon(
                                      Icons.check,
                                      color: Colors.green,
                                    )
                                  : Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                    ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                borderSide: BorderSide(
                                  color: CupertinoDynamicColor.withBrightness(
                                    color: Color(0x33000000),
                                    darkColor: Color(0x33FFFFFF),
                                  ),
                                  style: BorderStyle.solid,
                                  width: 0.0,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                borderSide: BorderSide(
                                  color: CupertinoDynamicColor.withBrightness(
                                    color: Color(0x33000000),
                                    darkColor: Color(0x33FFFFFF),
                                  ),
                                  style: BorderStyle.solid,
                                  width: 0.0,
                                ),
                              ),
                              labelText: "Bio",
                              labelStyle: TextStyle(fontSize: 15.0),
                              hintText: "Max 50 characters"),
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: submit,
                        child: Container(
                          padding: EdgeInsets.all(7.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7.0),
                          ),
                          child: Text(
                            flagName && flagBio ? 'Update Profile' : 'Error',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20.0,
                            ),
                          ),
                        ),
                      ),
                      FlatButton.icon(
                          onPressed: logout,
                          icon: Icon(
                            Icons.clear,
                            color: Colors.red,
                          ),
                          label: Text(
                            'Logout',
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ))
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shareit/widgets/header.dart';

import '../searchservice.dart';

bool flag = true;
final usersRef = Firestore.instance.collection('users');

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  String username;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  String submitKey;
  //final _formKey = GlobalKey<FormState>();
  var queryResultSet = [];
  var tempSearchStore = [];

  submit() {
    if (username == null || username.length < 3) {
      setState(() {
        submitKey = 'Username is not accepted';
      });
    }
    if (flag) {
      SnackBar snackBar = SnackBar(
        content: Text(
          'Welcome $username',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      );
      _scaffoldKey.currentState.showSnackBar(snackBar);
      Timer(Duration(seconds: 2), () {
        Navigator.pop(context, username);
      });
    }
  }

  initiateSearch(value) {
    if (value.length == 0) {
      setState(() {
        queryResultSet = [];
        tempSearchStore = [];
      });
    }
    if (tempSearchStore.contains(value)) {
      setState(() {
        submitKey = 'Username is taken';
        flag = false;
      });
    } else {
      setState(() {
        submitKey = value.length < 3 ? 'Username is too short' : 'Submit';
        if (submitKey == 'Submit') {
          flag = true;
        } else {
          flag = false;
        }
      });
    }
    if (value.length == 1) {
      SearchService().searchByName(value).then((QuerySnapshot docs) {
        for (int i = 0; i < docs.documents.length; i++) {
          queryResultSet.add(docs.documents[i].data);
        }
      });
    } else {
      tempSearchStore = [];
      queryResultSet.forEach((element) {
        if (element['username'].startsWith(value)) {
          tempSearchStore.add(element['username']);
        }
      });
    }
  }

  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: header(isAppTitle: false, appTitle: 'Set up your profile'),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 25.0),
                  child: Text(
                    'Create a username',
                    style: TextStyle(fontSize: 25.0),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Container(
                    child: Form(
                      child: TextFormField(
                        onChanged: (values) {
                          username = values;
                          initiateSearch(values);
                        },
                        inputFormatters: [
                          BlacklistingTextInputFormatter(
                              new RegExp('[\\-|\\ ]'))
                        ],
                        decoration: InputDecoration(
                            suffixIcon: flag
                                ? Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  )
                                : Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    semanticLabel: submitKey,
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
                            labelText: "Username",
                            //focusColor: Color(0xff424242),
                            labelStyle: TextStyle(fontSize: 15.0),
                            hintText: "Must be at least 3 character"),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: submit,
                  child: Container(
                    padding: EdgeInsets.all(7.0),
                    decoration: BoxDecoration(
                      //color: flag ? Colors.grey : Colors.redAccent,
                      borderRadius: BorderRadius.circular(7.0),
                    ),
                    child: Text(
                      flag ? 'Submit' : submitKey,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

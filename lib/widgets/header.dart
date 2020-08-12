import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shareit/models/user.dart';
import 'package:shareit/msgList.dart';

AppBar header(
    {bool isAppTitle = false,
    String appTitle = '',
    BuildContext context,
    User currentUser}) {
  return AppBar(
    automaticallyImplyLeading: false,
    title: Text(
      isAppTitle ? "ShareIt" : appTitle,
      style: TextStyle(
        color: Colors.white,
        fontFamily: isAppTitle ? 'Signatra' : '',
        fontSize: isAppTitle ? 50.0 : 22.0,
      ),
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: true,
    actions: isAppTitle
        ? <Widget>[
            IconButton(
                icon: Icon(Icons.textsms),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return MessageList(
                        currentUser: currentUser,
                      );
                    }),
                  );
                })
          ]
        : null,
    backgroundColor: Color(0xff424242),
  );
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shareit/chat.dart';
import 'package:shareit/widgets/header.dart';
import 'package:shareit/widgets/progress.dart';

import 'models/user.dart';

class MessageList extends StatefulWidget {
  final User currentUser;

  const MessageList({this.currentUser});
  @override
  _MessageListState createState() => _MessageListState();
}

class _MessageListState extends State<MessageList> {
  buildMsgListSearchResult() {
    return FutureBuilder(
        future: msgUserRef
            .document(widget.currentUser.id)
            .collection('users')
            .getDocuments(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<UserResult> searchResults = [];
          snapshot.data.documents.forEach((doc) {
            User user = User.fromDocument(doc);
            UserResult searchResult = UserResult(
              currentUser: widget.currentUser,
              user: user,
            );
            searchResults.add(searchResult);
          });
          return ListView(
            children: searchResults,
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(appTitle: 'Messages'),
      body: buildMsgListSearchResult(),
    );
  }
}

class UserResult extends StatelessWidget {
  final User user;
  final User currentUser;
  UserResult({this.user, this.currentUser});
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return ChatScreen(
                  currentUser: currentUser,
                  profileId: user.id,
                );
              }));
            },
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(0xFF424242),
                backgroundImage: NetworkImage(user.photoUrl),
              ),
              title: Text(
                user.displayName,
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                user.username,
                style: TextStyle(color: Colors.black54),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

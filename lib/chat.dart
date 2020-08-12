import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shareit/pages/home.dart';
import 'constants.dart';
import 'models/user.dart';

final timeStamp = DateTime.now();
int i = 0;
final msgUserRef = Firestore.instance.collection('messageUser');

class ChatScreen extends StatefulWidget {
  final User currentUser;
  final String profileId;
  const ChatScreen({this.currentUser, this.profileId});
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String text;
  int messageCount = 0;
  final TextEditingController clearText = TextEditingController();

  @override
  void initState() {
    super.initState();
    getMessageCount();
    getMessageUser();
  }

  getMessageCount() async {
    QuerySnapshot snapshot = await messageRef
        .document(currentUser.id)
        .collection('users')
        .document(widget.profileId)
        .collection('messages')
        .getDocuments();
    setState(() {
      messageCount = snapshot.documents.length;
    });
  }

  getMessageUser() async {
    DocumentSnapshot profileUserDoc =
        await usersRef.document(widget.profileId).get();
    DocumentSnapshot currentUserDoc =
        await usersRef.document(currentUser.id).get();
    User profileUserData = User.fromDocument(profileUserDoc);
    User currentUserData = User.fromDocument(currentUserDoc);
    QuerySnapshot snapshot = await msgUserRef
        .document(currentUser.id)
        .collection('users')
        .getDocuments();
    if (snapshot.documents.length == 0) {
      msgUserRef
          .document(currentUser.id)
          .collection('users')
          .document(widget.profileId)
          .setData({
        'bio': '',
        'id': profileUserData.id,
        'displayName': profileUserData.displayName,
        'username': profileUserData.username,
        'photoUrl': profileUserData.photoUrl,
        'email': profileUserData.email,
      });
      msgUserRef
          .document(widget.profileId)
          .collection('users')
          .document(currentUser.id)
          .setData({
        'bio': '',
        'id': currentUserData.id,
        'displayName': currentUserData.displayName,
        'username': currentUserData.username,
        'photoUrl': currentUserData.photoUrl,
        'email': currentUserData.email,
      });
    } else {
      List<DocumentSnapshot> docList = snapshot.documents;
      if (!docList.contains(widget.profileId)) {
        msgUserRef
            .document(currentUser.id)
            .collection('users')
            .document(widget.profileId)
            .setData({
          'bio': '',
          'id': profileUserData.id,
          'displayName': profileUserData.displayName,
          'username': profileUserData.username,
          'photoUrl': profileUserData.photoUrl,
          'email': profileUserData.email,
        });
        msgUserRef
            .document(widget.profileId)
            .collection('users')
            .document(currentUser.id)
            .setData({
          'bio': '',
          'id': currentUserData.id,
          'displayName': currentUserData.displayName,
          'username': currentUserData.username,
          'photoUrl': currentUserData.photoUrl,
          'email': currentUserData.email,
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print(widget.profileId);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            MessageStream(
                profileId: widget.profileId, currentUserId: currentUser.id),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: clearText,
                      onChanged: (value) {
                        text = value;
                      },
                      style: TextStyle(color: Colors.lightBlueAccent),
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageRef
                          .document(currentUser.id)
                          .collection('users')
                          .document(widget.profileId)
                          .collection('messages')
                          .add({
                        'index': messageCount,
                        'text': text,
                        'id': currentUser.id,
                        'sender': currentUser.username,
                        'timeStamp': timeStamp,
                      });
                      messageRef
                          .document(widget.profileId)
                          .collection('users')
                          .document(currentUser.id)
                          .collection('messages')
                          .add({
                        'index': messageCount,
                        'text': text,
                        'id': currentUser.id,
                        'sender': currentUser.username,
                        'timeStamp': timeStamp,
                      });
                      setState(() {
                        clearText.clear();
                        getMessageCount();
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageStream extends StatelessWidget {
  final String profileId, currentUserId;

  const MessageStream({this.profileId, this.currentUserId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: messageRef
          .document(currentUserId)
          .collection('users')
          .document(profileId)
          .collection('messages')
          .orderBy('index', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.black,
            ),
          );
        }
        final messages = snapshot.data.documents;
        List<MessageBubble> messageBubbles = [];
        for (var msg in messages) {
          final messageText = msg.data['text'];
          final messageSender = msg.data['sender'];
          final senderId = msg.data['id'];
          MessageBubble messageBubble;
          if (senderId == currentUserId) {
            messageBubble = MessageBubble(
                messageText: messageText,
                messageSender: messageSender,
                isMe: true);
          } else {
            messageBubble = MessageBubble(
                messageText: messageText,
                messageSender: messageSender,
                isMe: false);
          }
          messageBubbles.add(messageBubble);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.all(8),
            children: messageBubbles,
          ),
        );
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    Key key,
    @required this.messageText,
    @required this.messageSender,
    this.isMe,
  });

  final String messageText;
  final String messageSender;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            messageSender,
            style: TextStyle(color: Colors.black54, fontSize: 10),
          ),
          SizedBox(
            height: 5,
          ),
          Material(
            borderRadius: isMe
                ? BorderRadius.only(
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30))
                : BorderRadius.only(
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30)),
            elevation: 10,
            color: isMe ? Colors.black : Colors.grey,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                '$messageText',
                style: TextStyle(
                    color: isMe ? Colors.lightBlueAccent : Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

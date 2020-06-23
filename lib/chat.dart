import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shareit/pages/home.dart';
import 'package:shareit/pages/search.dart';
import 'package:shareit/widgets/progress.dart';
import 'constants.dart';
import 'models/user.dart';

final timeStamp = DateTime.now();
int i = 0;
final msgUserRef = Firestore.instance.collection('messageUser');

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  //final _auth = 1;// = FirebaseAuth.instance;
  String text;
  int messageCount = 0;
  String currentUser = " ";
  final TextEditingController clearText = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getMessageCount();
    //  getCurrentUser();
  }

  getCurrentUser() async {
    final GoogleSignInAccount user = GoogleSignIn().currentUser;
    currentUser = user.id;
    // await getMessageCount();
    try {
      if (currentUser != null) {
        //  loggedInUser = user;
        getMessages();
      }
    } catch (e) {
      print(e);
    }
  }

  getMessageCount() async {
    QuerySnapshot snapshot = await messageRef
        .document(currentUser)
        .collection('users')
        .getDocuments();
    setState(() {
      messageCount = snapshot.documents.length;
    });
  }

  getMessageUser() async {
    QuerySnapshot snapshot = await msgUserRef
        .document(currentUser)
        .collection('users')
        .getDocuments();
    for (var userData in snapshot.documents) {}
  }

  buildSearchResult() {
    return FutureBuilder(
        future:
            msgUserRef.document(currentUser).collection('users').getDocuments(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return circularProgress();
          }
          List<UserResult> searchResults = [];
          snapshot.data.documents.forEach((doc) {
            User user = User.fromDocument(doc);
            UserResult searchResult = UserResult(
              user: user,
            );
            searchResults.add(searchResult);
          });
          return ListView(
            children: searchResults,
          );
        });
  }

  getMessages() async {
    QuerySnapshot snapshot = await messageRef
        .document(currentUser)
        .collection('group')
        .getDocuments();
    for (var msg in snapshot.documents) {
      print(msg.data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                //              _auth.signOut();
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
            MessageStream(),
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
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      setState(() {
                        clearText.clear();
                      });
                      usersRef.add({
                        'text': text,
                        //'sender': loggedInUser.email,
                        'timeStamp': timeStamp,
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
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        /*stream: usersRef.orderBy('timeStamp', descending: true).snapshots(),
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
          MessageBubble messageBubble;
          if (messageSender == loggedInUser.email) {
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
      },*/
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

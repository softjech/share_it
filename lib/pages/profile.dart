import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:shareit/chat.dart';
import 'package:shareit/models/user.dart';
import 'package:shareit/pages/display_post.dart';
import 'package:shareit/pages/edit_profile.dart';
import 'package:shareit/widgets/header.dart';
import 'package:shareit/widgets/post.dart';
import 'package:shareit/widgets/progress.dart';

import 'home.dart';

int postCount = 0;

class Profile extends StatefulWidget {
  final String profileId;
  Profile({this.profileId});
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isFollowing = false;
  final String currentUserId = currentUser?.id;
  int followerCount = 0;
  int followingCount = 0;
  List idPost = [];
  List dataPost = [];
  List<Post> posts = [];
  @override
  void initState() {
    super.initState();
    getProfilePosts();
    getFollowers();
    getFollowing();
    getPostInfo();
    checkIfFollowing();
  }

  getPostInfo() async {
    QuerySnapshot snapshot = await postsRef
        .document(widget.profileId)
        .collection('userPosts')
        .getDocuments();
    snapshot.documents.forEach((doc) {
      if (doc.exists) {
        idPost.add(doc.documentID);
        dataPost.add(doc.data);
      }
    });
  }

  getFollowers() async {
    QuerySnapshot snapshot = await followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .getDocuments();
    setState(() {
      followerCount = snapshot.documents.length;
    });
  }

  getFollowing() async {
    QuerySnapshot snapshot = await followingRef
        .document(widget.profileId)
        .collection('userFollowing')
        .getDocuments();
    setState(() {
      followingCount = snapshot.documents.length;
    });
  }

  checkIfFollowing() async {
    DocumentSnapshot doc = await followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .get();
    setState(() {
      isFollowing = doc.exists;
    });
  }

  getProfilePosts() async {
    QuerySnapshot snapshot = await postsRef
        .document(widget.profileId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    setState(() {
      postCount = snapshot.documents.length;
    });
  }

  editProfile() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return EditProfile(currentUserId: currentUserId);
    }));
  }

  Container buildButton({String text, Function function}) {
    final Size size = MediaQuery.of(context).size;
    return Container(
      width: size.width,
      height: 40,
      padding: EdgeInsets.only(top: 2),
      child: FlatButton(
        onPressed: function,
        child: Container(
          child: Text(
            text,
            style: TextStyle(
                color: isFollowing ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold),
          ),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isFollowing ? Colors.blue : Colors.teal,
            border: Border.all(color: Colors.teal),
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }

  buildProfileButton() {
    bool isProfileOwner = currentUserId == widget.profileId;
    if (isProfileOwner) {
      return buildButton(
        text: 'Edit Profile',
        function: editProfile,
      );
    } else if (isFollowing) {
      return buildButton(text: 'Unfollow', function: handleUnfollowUser);
    } else if (!isFollowing) {
      return buildButton(text: 'Follow', function: handleFollowUser);
    }
  }

  handleFollowUser() {
    setState(() {
      isFollowing = true;
    });
    followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .setData({});
    followingRef
        .document(currentUserId)
        .collection('userFollowing')
        .document(widget.profileId)
        .setData({});
    activityFeedRef
        .document(widget.profileId)
        .collection('feedItems')
        .document(currentUserId)
        .setData({
      'type': 'follow',
      'ownerId': widget.profileId,
      'username': currentUser.username,
      'userId': currentUserId,
      'userProfileImg': currentUser.photoUrl,
      'timestamp': timestamp,
    });
    int i = 0;
    dataPost.forEach((data) {
      timelineRef
          .document(currentUserId)
          .collection('timelinePosts')
          .document(idPost[i])
          .setData(data);
      i = i + 1;
    });
  }

  handleUnfollowUser() {
    setState(() {
      isFollowing = false;
    });
    followersRef
        .document(widget.profileId)
        .collection('userFollowers')
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    followingRef
        .document(currentUserId)
        .collection('userFollowing')
        .document(widget.profileId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    activityFeedRef
        .document(widget.profileId)
        .collection('feedItems')
        .document(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
    idPost.forEach((id) {
      timelineRef
          .document(currentUserId)
          .collection('timelinePosts')
          .document(id)
          .get()
          .then((doc) {
        if (doc.exists) {
          doc.reference.delete();
        }
      });
    });
  }

  buildProfileHeader() {
    return FutureBuilder(
      future: usersRef.document(widget.profileId).get(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return circularProgress();
        }
        User user = User.fromDocument(snapshot.data);
        String name = user.displayName;
        String username = user.username;
        String bio = user.bio;
        final Size size = MediaQuery.of(context).size;
        return Stack(
          children: <Widget>[
            Positioned(
              top: 100,
              bottom: 0,
              child: Container(
                width: size.width,
                height: size.height,
                decoration: BoxDecoration(
                  color: Color(0xFF424242),
                  border: Border.all(
                      color: CupertinoDynamicColor.withBrightness(
                          color: Color(0x33FFFFFF),
                          darkColor: Color(0x33000000))
                      //width: 5.0,
                      ),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)),
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(top: 60),
                          child: Text(
                            name,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        Text(
                          '@$username',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 7,
                        ),
                        Text(
                          bio.length < 50 ? bio : bio.substring(0, 50),
                          style: TextStyle(
                              color: Colors.white,
                              //fontSize: 25,
                              fontWeight: FontWeight.w400),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Wrap(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Column(
                                    children: <Widget>[
                                      Text(
                                        '$postCount',
                                        style: TextStyle(
                                          color: Colors.teal,
                                          fontSize: 30,
                                        ),
                                      ),
                                      Text(
                                        'Posts',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 25,
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Text(
                                        '$followerCount',
                                        style: TextStyle(
                                          color: Colors.teal,
                                          fontSize: 30,
                                        ),
                                      ),
                                      Text(
                                        'Followers',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    width: 25,
                                  ),
                                  Column(
                                    children: <Widget>[
                                      Text(
                                        '$followingCount',
                                        style: TextStyle(
                                          color: Colors.teal,
                                          fontSize: 30,
                                        ),
                                      ),
                                      Text(
                                        'Following',
                                        style: TextStyle(
                                            color: Colors.white, fontSize: 20),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        buildProfileButton(),
                        SizedBox(
                          height: 20,
                        ),
                        buildButton(
                            text: 'Posts',
                            function: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return DisplayPost(
                                  profileId: widget.profileId,
                                );
                              }));
                            }),
                        SizedBox(
                          height: 20,
                        ),
                        currentUserId == widget.profileId
                            ? Text('')
                            : buildButton(
                                text: 'Message',
                                function: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return ChatScreen(
                                        //profileId: widget.profileId,
                                        );
                                  }));
                                }),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
                right: (size.width / 2) - 50,
                top: 50,
                child: CircleAvatar(
                  backgroundImage: NetworkImage(user.photoUrl),
                  backgroundColor: Colors.red,
                  radius: 50,
                ))
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0x11FFFFFF),
      appBar: header(isAppTitle: false, appTitle: 'Profile', context: context),
      body: Container(
        child: buildProfileHeader(),
      ),
    );
  }
}

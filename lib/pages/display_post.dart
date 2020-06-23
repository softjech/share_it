import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shareit/pages/profile.dart';
import 'package:shareit/widgets/header.dart';
import 'package:shareit/widgets/post.dart';
import 'package:shareit/widgets/post_tile.dart';
import 'package:shareit/widgets/progress.dart';
import 'home.dart';

class DisplayPost extends StatefulWidget {
  final String profileId;
  DisplayPost({this.profileId});
  @override
  _DisplayPostState createState() => _DisplayPostState();
}

class _DisplayPostState extends State<DisplayPost> {
  bool isLoading = false;
  List<Post> posts = [];
  String orientation = 'grid';
  @override
  void initState() {
    super.initState();
    getProfilePosts();
  }

  getProfilePosts() async {
    setState(() {
      isLoading = true;
    });
    QuerySnapshot snapshot = await postsRef
        .document(widget.profileId)
        .collection('userPosts')
        .orderBy('timestamp', descending: true)
        .getDocuments();
    setState(() {
      isLoading = false;
      postCount = snapshot.documents.length;
      posts = snapshot.documents.map((doc) => Post.fromDocument(doc)).toList();
    });
  }

  buildProfilePosts() {
    if (isLoading) {
      return circularProgress();
    } else if (posts.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/no_content.svg',
              height: 260.0,
            ),
            Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Text(
                'No Posts',
                style: TextStyle(
                    fontSize: 40.0,
                    color: Colors.red,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }
    if (orientation == 'grid') {
      List<GridTile> gridTile = [];
      posts.forEach((post) {
        gridTile.add(
          GridTile(
            child: PostTile(post: post),
          ),
        );
      });
      return GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 1.0,
        mainAxisSpacing: 1.5,
        crossAxisSpacing: 1.5,
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: gridTile,
      );
    } else if (orientation == 'list') {
      return Column(children: posts);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(isAppTitle: false, appTitle: 'Posts'),
      body: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: IconButton(
                    onPressed: () {
                      setState(() {
                        orientation = 'grid';
                      });
                    },
                    icon: Icon(
                      Icons.grid_on,
                      color: orientation == 'grid' ? Colors.teal : Colors.grey,
                    )),
              ),
              Expanded(
                child: IconButton(
                    onPressed: () {
                      setState(() {
                        orientation = 'list';
                      });
                    },
                    icon: Icon(
                      Icons.list,
                      color: orientation == 'list' ? Colors.teal : Colors.grey,
                    )),
              ),
            ],
          ),
          isLoading ? circularProgress() : buildProfilePosts(),
        ],
      ),
    );
  }
}

//import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shareit/models/user.dart';
import 'package:shareit/pages/create_account.dart';
import 'package:shareit/widgets/progress.dart';

import 'activity_feed.dart';

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search>
    with AutomaticKeepAliveClientMixin<Search> {
  TextEditingController searchController = TextEditingController();
  Future<QuerySnapshot> searchResultsFuture;
  bool flag;
  handleSearch(String query) {
    flag = false;
    Future<QuerySnapshot> users = usersRef
        .where('displayName', isLessThanOrEqualTo: query)
        .getDocuments();
    users.then((value) {
      var x = value.documents;
      if (x.isEmpty) {
        users = usersRef
            .where('displayName', isLessThanOrEqualTo: query)
            .getDocuments();
      } else {
        flag = true;
      }
    });

    setState(() {
      searchResultsFuture = flag ? users : users;
    });
  }

  clearInput() {
    searchController.clear();
  }

  AppBar buildSearchField() {
    return AppBar(
      backgroundColor: Color(0xFF424242),
      title: TextFormField(
        controller: searchController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 0),
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(
              color: CupertinoDynamicColor.withBrightness(
                color: Color(0x33000000),
                darkColor: Color(0x33FFFFFF),
              ),
              style: BorderStyle.solid,
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
            ),
          ),
          hintText: "Search for a user...",
          filled: true,
          prefixIcon: Icon(
            Icons.person_add,
            size: 28.0,
          ),
          suffixIcon: IconButton(
            icon: Icon(Icons.clear),
            onPressed: clearInput,
          ),
        ),
        onFieldSubmitted: handleSearch,
        onChanged: (value) {
          handleSearch(value);
        },
      ),
    );
  }

  Container buildNoContent() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            SvgPicture.asset(
              'assets/images/search.svg',
              height: orientation == Orientation.portrait ? 300.0 : 190.0,
            ),
            SizedBox(
              height: 20.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  CupertinoIcons.search,
                  size: 45.0,
                  color: Colors.grey,
                ),
                Text(
                  "Find Users",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                    fontSize: 30.0,
                    fontStyle: FontStyle.italic,
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  buildSearchResult() {
    return FutureBuilder(
        future: searchResultsFuture,
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

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: buildSearchField(),
      body:
          searchResultsFuture == null ? buildNoContent() : buildSearchResult(),
    );
  }
}

class UserResult extends StatelessWidget {
  final User user;
  UserResult({this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          GestureDetector(
            onTap: () => showProfile(context, profileId: user.id),
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

import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image/image.dart' as Im;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shareit/models/user.dart';
import 'package:shareit/pages/home.dart';
import 'package:shareit/widgets/progress.dart';
import 'package:uuid/uuid.dart';

class Upload extends StatefulWidget {
  final User currentUser;

  Upload({this.currentUser});
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload>
    with AutomaticKeepAliveClientMixin<Upload> {
  File file;
  TextEditingController captionController = TextEditingController();
  TextEditingController locationController = TextEditingController();
  User currentUser;
  bool isUploading = false;
  String postId = Uuid().v4();
  String location;
  String caption;
  handleTakePhoto() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 675,
      maxWidth: 960,
    );
    setState(() {
      this.file = file;
    });
  }

  handleChooseFromGallery() async {
    Navigator.pop(context);
    File file = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      this.file = file;
    });
  }

  selectImage(parentContext) {
    return showDialog(
      context: parentContext,
      builder: (context) {
        return SimpleDialog(
          elevation: 50,
          backgroundColor: Color(0xFF424242),
          //contentPadding: EdgeInsets.all(20.0),
          titlePadding: EdgeInsets.only(top: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          title: Center(
              child: Text(
            'Create Post',
            style: TextStyle(color: Colors.white, fontSize: 30.0),
          )),
          children: <Widget>[
            SimpleDialogOption(
              child: Row(
                children: <Widget>[
                  Icon(
                    CupertinoIcons.photo_camera,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Text('Photo with Camera',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                      )),
                ],
              ),
              onPressed: handleTakePhoto,
            ),
            SimpleDialogOption(
              onPressed: handleChooseFromGallery,
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.image,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Text('Image from Gallery',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                      )),
                ],
              ),
            ),
            SimpleDialogOption(
              child: Row(
                children: <Widget>[
                  Icon(
                    Icons.cancel,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 10.0,
                  ),
                  Text('Cancel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                      )),
                ],
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  Container buildSplashScreen() {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SvgPicture.asset(
            'assets/images/upload.svg',
            height: 260.0,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0),
              ),
              child: Text(
                'Upload Image',
                style: TextStyle(fontSize: 22.0, color: Colors.white),
              ),
              color: Color(0xFF424242),
              onPressed: () => selectImage(context),
            ),
          ),
        ],
      ),
    );
  }

  compressImage() async {
    final tempDir = await getTemporaryDirectory();
    final path = tempDir.path;
    Im.Image imageFile = Im.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(Im.encodeJpg(imageFile, quality: 85));
    setState(() {
      file = compressedImageFile;
    });
  }

  Future<String> uploadImage(imageFile) async {
    StorageUploadTask uploadTask =
        storageRf.child('post_$postId.jpg').putFile(imageFile);
    StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
    String downloadUrl = await storageTaskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  createPostInFirestore(
      {String mediaUrl, String location, String description}) {
    postsRef
        .document(currentUser.id)
        .collection("userPosts")
        .document(postId)
        .setData({
      'postId': postId,
      'ownerId': currentUser.id,
      'username': currentUser.username,
      'mediaUrl': mediaUrl,
      'description': description,
      'location': location,
      'timestamp': timestamp,
      'likes': {},
    });

    timelineRef
        .document(currentUser.id)
        .collection('timelinePosts')
        .document(postId)
        .setData({
      'postId': postId,
      'ownerId': currentUser.id,
      'username': currentUser.username,
      'mediaUrl': mediaUrl,
      'description': description,
      'location': location,
      'timestamp': timestamp,
      'likes': {},
    });
  }

  handleSubmit() async {
    setState(() {
      isUploading = true;
    });
    await compressImage();
    String mediaUrl = await uploadImage(file);
    createPostInFirestore(
      mediaUrl: mediaUrl,
      location: locationController.text,
      description: captionController.text,
    );

    captionController.clear();
    locationController.clear();
    setState(() {
      file = null;
      isUploading = false;
      postId = Uuid().v4();
    });
  }

  buildUploadForm() {
    final Orientation orientation = MediaQuery.of(context).orientation;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Caption Post',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF424242),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios),
          color: Colors.white,
          onPressed: isUploading
              ? null
              : () {
                  setState(() {
                    file = null;
                  });
                },
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.check,
              color: Colors.teal,
            ),
            onPressed: isUploading ? null : () => handleSubmit(),
          )
        ],
      ),
      body: Container(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            isUploading ? linearProgress() : Text(''),
            Card(
              child: Container(
                height: orientation == Orientation.portrait ? 300.0 : 250.0,
                child: Image.file(file),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            ListTile(
              leading: CircleAvatar(
                backgroundImage: NetworkImage(currentUser.photoUrl),
                backgroundColor: Color(0xFF424242),
              ),
              title: TextFormField(
                controller: captionController,
                decoration: InputDecoration(
                  labelText: 'Caption',
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide(
                      color: CupertinoDynamicColor.withBrightness(
                        color: Color(0x33000000),
                        darkColor: Color(0x33FFFFFF),
                      ),
                      style: BorderStyle.solid,
                    ),
                  ),
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
                ),
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            ListTile(
              leading: Icon(
                Icons.location_on,
                color: CupertinoColors.black,
                size: 35,
              ),
              title: TextFormField(
                controller: locationController,
                decoration: InputDecoration(
                  hintText: 'Where was this photo taken?',
                  labelText: 'Location',
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15.0),
                    borderSide: BorderSide(
                      color: CupertinoDynamicColor.withBrightness(
                        color: Color(0x33000000),
                        darkColor: Color(0x33FFFFFF),
                      ),
                      style: BorderStyle.solid,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: CupertinoDynamicColor.withBrightness(
                        color: Color(0x33000000),
                        darkColor: Color(0x33FFFFFF),
                      ),
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
            Container(
              width: 200.0,
              height: 100.0,
              alignment: Alignment.center,
              child: RaisedButton.icon(
                onPressed: getUserLocation,
                icon: Icon(
                  Icons.my_location,
                  color: Colors.white,
                ),
                label: Text(
                  'Use Current Location',
                  style: TextStyle(color: Colors.white),
                ),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0)),
                color: Color(0xFF424242),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> getUserLocation() async {
    try {
      GeolocationStatus geolocationStatus =
          await Geolocator().checkGeolocationPermissionStatus();
      print(geolocationStatus);
      Position position = await Geolocator()
          .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      List<Placemark> placemarks = await Geolocator()
          .placemarkFromCoordinates(position.latitude, position.longitude);
      Placemark placemark = placemarks[0];
      String formattedAddress = '${placemark.locality}, ${placemark.country}';
      locationController.text = formattedAddress;
    } catch (e) {
      print(e);
    }
  }

  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    currentUser = widget.currentUser;
    return file == null ? buildSplashScreen() : buildUploadForm();
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';

import 'models/user_data.dart';
import 'services/authentication_check.dart';
import 'services/auth_service.dart';

class Profile extends StatefulWidget {
  final BaseAuth auth;
  final String email;

  Profile({this.auth, this.email});

  @override
  State<StatefulWidget> createState() {
    return _ProfileState();
  }
}

class _ProfileState extends State<Profile> {
  User _user;
  File image, _cachedImage;
  StorageTaskSnapshot picDownloader;
  String picUrl, confirmedPicUrl;

  @override
  void initState() {
    super.initState();
    setState(() {
      _user = User(email: widget.email);
    });
    downloadFile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Martian Profile', style: TextStyle(fontWeight: FontWeight.bold),),
      ),
      body: _showBody(),
    );
  }

  Widget _showBody() {
    return ListView(
      padding: EdgeInsets.only(top: 35),
      children: <Widget>[
        _profilePicture(),
      ],
    );
  }

  Future<void> getImageAndUpload(ImageSource source) async {
    var tempImage = await ImagePicker.pickImage(source: source);
    setState(() {
      image = tempImage;
    });
    StorageReference ref = FirebaseStorage.instance
        .ref()
        .child('${widget.email}_profile_picture.jpg');
    StorageUploadTask task = ref.putFile(image);
    await addProfilePhoto(task);
  }

  Future<void> addProfilePhoto(StorageUploadTask task) async {
    picDownloader = await task.onComplete;
    picUrl = await picDownloader.ref.getDownloadURL();
    await _user.addField('profilePic', picUrl);
  }

  Future<Null> downloadFile() async {
    final String filePath = '${widget.email}_profile_picture.jpg';
    final Directory tempDir = Directory.systemTemp;
    final File file = File('${tempDir.path}/$filePath');

    final StorageReference ref = FirebaseStorage.instance.ref().child(filePath);
    final StorageFileDownloadTask downloadTask = ref.writeToFile(file);

    final int byteNumber = (await downloadTask.future).totalByteCount;
    print(byteNumber);
    setState(() {
      _cachedImage = file;
      print(_cachedImage.path);
    });
  }

  void _profilePicOption() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            content: Container(
              height: 260,
              child: Column(
                children: <Widget>[
                  Card(
                      elevation: 0,
                      borderOnForeground: false,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Container(
                          decoration:
                              BoxDecoration(color: Colors.deepOrangeAccent),
                          padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                          child: Center(
                            child: Text(
                              'Profile Picture',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ))),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                      width: 250,
                      child: RaisedButton(
                        color: Colors.white,
                        padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.camera_alt,
                              color: Colors.deepOrange,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Take Picture',
                              style: TextStyle(
                                  color: Colors.deepOrange, fontSize: 20),
                            ),
                          ],
                        ),
                        elevation: 20,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        onPressed: () async {
                          Navigator.pop(context);
                          await getImageAndUpload(ImageSource.camera);
                        },
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                      width: 250,
                      child: RaisedButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Choose from Gallery',
                              style: TextStyle(color: Colors.deepOrange),
                            ),
                          ],
                        ),
                        elevation: 20,
                        color: Colors.white,
                        padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        onPressed: () async {
                          Navigator.pop(context);
                          await getImageAndUpload(ImageSource.gallery);
                        },
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                      width: 150,
                      child: RaisedButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Delete',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                        elevation: 20,
                        color: Colors.red,
                        padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        onPressed: () async {
                          Navigator.pop(context);
                          _cachedImage.delete();
                        },
                      )),
                ],
              ),
            ),
          );
        });
  }

  Widget _profilePicture() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white, width: 10),
            boxShadow: [
              BoxShadow(
                  color: Colors.black26,
                  offset: Offset(2, 0),
                  blurRadius: 25,
                  spreadRadius: 1)
            ]),
        height: 200,
        width: 200,
        child: InkWell(
          onTap: () => _profilePicOption(),
          child: _cachedImage == null
              ? Image.asset('assets/mars_profile.jpg')
              : Image.asset(
                  _cachedImage.path,
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }
}

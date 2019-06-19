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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Martian Records'),
      ),
      body: _showBody(),
    );
  }

  Widget _showBody() {
    return Column(
      children: <Widget>[
        _uploadPhoto(),
      ],
    );
  }

  Future<void> getImage() async {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      image = tempImage;
    });
  }

  Future<void> addProfilePhoto(StorageUploadTask task) async {
    picDownloader = await task.onComplete;
    picUrl = await picDownloader.ref.getDownloadURL();
    await _user.addField('profilePic', picUrl);
  }

//  Future<void> getImageFromFirebase() async {
//    final ByteData byteData = await rootBundle.load('${widget.email}_profile_picture.jpg');
//    final Directory tempDir = Directory.systemTemp;
//    confirmedPicUrl = await _user.getField('profilePic');
//    final File file = File('${tempDir.path}/$confirmedPicUrl');
//    file.writeAsBytes(byteData.buffer.asInt8List(), mode: FileMode.write);
//    print(confirmedPicUrl);
//  }

  Future<Null> downloadFile() async {
    final String filePath = '${widget.email}_profile_picture.jpg';
    final Directory tempDir = Directory.systemTemp;
    final File file  = File('${tempDir.path}/$filePath');

    final StorageReference ref =  FirebaseStorage.instance.ref().child(filePath);
    final StorageFileDownloadTask downloadTask = ref.writeToFile(file);

    final int byteNumber = (await downloadTask.future).totalByteCount;
    print(byteNumber);

    setState(() {
      _cachedImage =  file;
    });
  }

  Widget _uploadPhoto() {
    return Container(
      child: Column(
        children: <Widget>[
          _cachedImage == null
              ? Text('Select an Image')
              : Image.asset(
                  _cachedImage.path,
                ),
          FlatButton(
            child: Text('Take pic'),
            onPressed: () {
              getImage();
            },
          ),
          FlatButton(
            child: Text('Upload pic'),
            onPressed: () {
              StorageReference ref = FirebaseStorage.instance
                  .ref()
                  .child('${widget.email}_profile_picture.jpg');
              StorageUploadTask task = ref.putFile(image);
              addProfilePhoto(task);
            },
          ),
          FlatButton(
            child: Text('Download File'),
            onPressed: () async {
              await downloadFile();
            },
          )
        ],
      ),
    );
  }
}

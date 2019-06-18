import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';

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
  File image;

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

  Widget _uploadPhoto() {
    return Container(
      child: Column(
        children: <Widget>[
          image == null
              ? Text('Select an Image')
              : Image.file(
                  image,
                  height: 300,
                  width: 300,
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
              StorageReference ref = FirebaseStorage.instance.ref().child('${widget.email}_1');
              StorageUploadTask tast = ref.putFile(image);
            },
          )
        ],
      ),
    );
  }
}

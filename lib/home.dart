import 'package:flutter/material.dart';
import 'package:project_martian/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'root.dart';

class HomePage extends StatefulWidget {
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;
  final String email;

  HomePage({this.auth, this.onSignedOut, this.userId, this.email});

  @override
  State<StatefulWidget> createState() {

    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.email),
        actions: <Widget>[_showLogOutButton()],
      ),
      body: _showLogo(),
    );
  }

  Widget _showLogo() {
    return Hero(
      tag: 'marsLogo',
      child: Container(
        alignment: Alignment.topCenter,
        padding: EdgeInsets.fromLTRB(0, 30, 0, 50),
        child: Text(
          'Martian',
          style: TextStyle(
              fontSize: 50,
              color: Colors.deepOrangeAccent,
              fontFamily: 'SamsungOne',
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _showLogOutButton() {
    return IconButton(
        tooltip: 'Logout',
        iconSize: 25,
        icon: Icon(
          Icons.close,
          color: Colors.white,
        ),
        onPressed: () {
          _signOut();
        });
  }

  void _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:project_martian/services/auth_service.dart';
import 'root.dart';

class HomePage extends StatefulWidget {
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String userId;

  HomePage({this.auth, this.onSignedOut, this.userId});

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Welcome'),
        actions: <Widget>[_showLogOutButton()],
      ),
    );
  }

  Widget _showLogOutButton() {
    return IconButton(tooltip: 'Logout',
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

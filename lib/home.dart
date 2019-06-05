import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  String _email;

  HomePage(this._email);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome $_email'),
      ),
    );
  }
}

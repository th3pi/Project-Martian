import 'package:flutter/material.dart';

class Auth extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AuthState();
  }
}

class _AuthState extends State<Auth> {
  String _email, _password;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.deepOrange,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          'Login',
          style: (TextStyle(
              color: Colors.deepOrangeAccent,
              fontFamily: 'SamsungOne',
              fontWeight: FontWeight.bold)),
        ),
      ),
      body: _showLogo(),
    );
  }

  Widget _showLogo() {
    return Hero(
      tag: 'Hero',
      child: Container(
        padding: EdgeInsets.fromLTRB(0, 70, 0, 0),
        child: Text(
          'Martian',
          style: TextStyle(color: Colors.white, fontFamily: 'SamsungOne'),
        ),
      ),
    );
  }

  Widget _showEmailInput() {
    return Container(
      padding: const EdgeInsets.fromLTRB(0, 100, 0, 0),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: InputDecoration(labelText: 'Email'),
        validator: (String value) => value.isEmpty ? 'Email can\'t be empty' : null,
        onSaved: (value) => _email = value,
      ),
    );
  }
}

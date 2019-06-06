import 'package:flutter/material.dart';
import 'models/new_user.dart';
import 'home.dart';
import './services/auth_service.dart';
import 'root.dart';

class CreateAccountPage extends StatefulWidget {
  final String userId;
  final BaseAuth auth;

  CreateAccountPage({this.userId, this.auth});

  @override
  State<StatefulWidget> createState() {
    return _CreateAccountPageState();
  }
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();
  String _firstName, _lastName, _motherPlanet;
  num _gsid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Visitor Pass Application',
          ),
        ),
        body: _showBody());
  }

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void _validateAndSubmit() async {
    if (_validateAndSave()) {
      print(_firstName);
      User(userId: widget.userId,
          firstName: _firstName,
          lastName: _lastName,
          mother_planet: _motherPlanet,
          gsid: _gsid);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext) => RootPage(auth: widget.auth,)));
    }
  }

  Widget _showBody() {
    return Container(
      child: Form(
        key: _formKey,
        child: ListView(
          children: <Widget>[
            _showFirstNameInput(),
            _showLastNameInput(),
            _showMotherPlanetInput(),
            _showGsidInput(),
            _showDoneButton()
          ],
        ),
      ),
    );
  }

  Widget _showDoneButton() {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: RaisedButton(
        padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        splashColor: Colors.orangeAccent,
        elevation: 5,
        color: Colors.white,
        child: Text(
          'Done',
          style: TextStyle(
              fontSize: 20,
              color: Colors.deepOrangeAccent,
              fontFamily: 'SamsungOne'),
        ),
        onPressed: _validateAndSubmit,
      ),
    );
  }

  Widget _showFirstNameInput() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.white, offset: Offset(2, 0), blurRadius: 5)
          ]),
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
      child: TextFormField(
        cursorColor: Colors.deepOrangeAccent,
        maxLines: 1,
        decoration: InputDecoration(
          labelStyle: TextStyle(fontFamily: 'SamsungOne'),
          labelText: 'First Name',
        ),
        validator: (value) => value.isEmpty ? 'First Name is required' : null,
        onSaved: (value) => _firstName = value,
      ),
    );
  }

  Widget _showLastNameInput() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.white, offset: Offset(2, 0), blurRadius: 5)
          ]),
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
      child: TextFormField(
        cursorColor: Colors.deepOrangeAccent,
        maxLines: 1,
        decoration: InputDecoration(
          labelStyle: TextStyle(fontFamily: 'SamsungOne'),
          labelText: 'Last Name',
        ),
        validator: (value) => value.isEmpty ? 'Last Name is required' : null,
        onSaved: (value) => _lastName = value,
      ),
    );
  }

  Widget _showMotherPlanetInput() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.white, offset: Offset(2, 0), blurRadius: 5)
          ]),
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
      child: TextFormField(
        cursorColor: Colors.deepOrangeAccent,
        maxLines: 1,
        decoration: InputDecoration(
          labelStyle: TextStyle(fontFamily: 'SamsungOne'),
          labelText: 'Planet of Origin',
        ),
        validator: (value) =>
            value.isEmpty ? 'Origin planet is required' : null,
        onSaved: (value) => _motherPlanet = value,
      ),
    );
  }

  Widget _showGsidInput() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.white, offset: Offset(2, 0), blurRadius: 5)
          ]),
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
      child: TextFormField(
        cursorColor: Colors.deepOrangeAccent,
        maxLines: 1,
        decoration: InputDecoration(
          labelStyle: TextStyle(fontFamily: 'SamsungOne'),
          labelText: 'Global Security ID',
        ),
        validator: (value) =>
            value.isEmpty ? 'Global Security ID is required' : null,
        onSaved: (value) => _gsid = num.parse(value),
      ),
    );
  }
}

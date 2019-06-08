import 'package:flutter/material.dart';
import 'models/new_user.dart';
import './services/auth_service.dart';
import 'package:flutter_picker/flutter_picker.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';

import 'home.dart';
import 'root.dart';

class CreateAccountPage extends StatefulWidget {
  final String userId;
  final BaseAuth auth;
  final String email;
  final VoidCallback onCancel;

  CreateAccountPage({this.userId, this.auth, this.email, this.onCancel});

  @override
  State<StatefulWidget> createState() {
    return _CreateAccountPageState();
  }
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();
  String _firstName,
      _lastName,
      _motherPlanet,
      _dateOfBirth = 'Date of Birth',
      _species,
      _gender,
      _reason = 'Tourist';
  num _gsid;
  String tourist = 'Tourist',
      business = 'Business',
      family = 'Visiting family',
      asylum = 'Seeking Asylum',
      immigration = 'Moving to Mars';
  final FocusNode firstFocus = FocusNode(),
      secondFocus = FocusNode(),
      thirdForcus = FocusNode(),
      fourthFocus = FocusNode(),
      fifthFocus = FocusNode(),
      sixthFocus = FocusNode(),
      seventhFocus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.deepOrange,
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Text(
            'Visitor Pass Application',
            style: TextStyle(
                color: Colors.deepOrangeAccent, fontWeight: FontWeight.bold),
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
      User(
          userId: widget.userId,
          firstName: _firstName,
          lastName: _lastName,
          mother_planet: _motherPlanet,
          gsid: _gsid,
          dateOfBirth: _dateOfBirth,
          gender: _gender,
          species: _species,
          email: widget.email,
          reason: _reason,
          martian: false);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext) => RootPage(
                    auth: widget.auth,
                  )));
    }
  }

  Widget _showBody() {
    return Container(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
          children: <Widget>[
            _showLogo(),
            _showFirstNameInput(),
            _showLastNameInput(),
            _showMotherPlanetInput(),
            _showGsidInput(),
            _showReasonForVisit(),
            _showSecondaryQueries(),
            _showTermsAndConditions(),
            _showDoneButton(),
            _showCancelButton()
          ],
        ),
      ),
    );
  }

  Widget _showLogo() {
    return Hero(
      tag: 'marsLogo',
      child: Center(
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 15, 0, 4),
          child: Text(
            'Martian',
            style: TextStyle(
                fontSize: 25,
                color: Colors.white,
                fontFamily: 'SamsungOne',
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _showTermsAndConditions() {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
      child: Text(
        'By clicking done you are accepting the laws of the Martian land. Violation of these rules could result immediate termination of visitor\'s pass or upto lifetime detention in the Martian Detention Facility',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
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
        autofocus: true,
        cursorColor: Colors.deepOrangeAccent,
        maxLines: 1,
        decoration: InputDecoration(
          labelStyle: TextStyle(fontFamily: 'SamsungOne'),
          labelText: 'First Name',
        ),
        validator: (value) => value.isEmpty ? 'First Name is required' : null,
        onSaved: (value) => _firstName = value,
        onFieldSubmitted: (value) {
          FocusScope.of(context).requestFocus(firstFocus);
        },
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
        focusNode: firstFocus,
        cursorColor: Colors.deepOrangeAccent,
        maxLines: 1,
        decoration: InputDecoration(
          labelStyle: TextStyle(fontFamily: 'SamsungOne'),
          labelText: 'Last Name',
        ),
        validator: (value) => value.isEmpty ? 'Last Name is required' : null,
        onSaved: (value) => _lastName = value,
        onFieldSubmitted: (value) {
          FocusScope.of(context).requestFocus(secondFocus);
        },
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
        focusNode: secondFocus,
        cursorColor: Colors.deepOrangeAccent,
        maxLines: 1,
        decoration: InputDecoration(
          labelStyle: TextStyle(fontFamily: 'SamsungOne'),
          labelText: 'Planet of Origin',
        ),
        validator: (value) =>
            value.isEmpty ? 'Origin planet is required' : null,
        onSaved: (value) => _motherPlanet = value,
        onFieldSubmitted: (value) {
          FocusScope.of(context).requestFocus(thirdForcus);
        },
      ),
    );
  }

  Widget _showSecondaryQueries() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.white, offset: Offset(2, 0), blurRadius: 5)
          ]),
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
      child: Row(
        children: <Widget>[
          Flexible(
            fit: FlexFit.tight,
            child: Container(
              child: FlatButton(
                child: Text(
                  _dateOfBirth,
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
                onPressed: () {
                  DatePicker.showDatePicker(context,
                      showTitleActions: true,
                      minTime: DateTime(2800, 3, 5),
                      maxTime: DateTime(3010, 6, 7), onConfirm: (date) {
                    setState(() {
                      _dateOfBirth = '${date.month}/${date.day}/${date.year}';
                    });
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: TextFormField(
              focusNode: fifthFocus,
              decoration: InputDecoration(
                hintText: 'Drom',
                labelStyle: TextStyle(fontFamily: 'SamsungOne'),
                labelText: 'Gender',
              ),
              validator: (value) =>
                  value.isEmpty ? 'Date of Birth is required' : null,
              onSaved: (value) => _gender = value,
              onFieldSubmitted: (value) {
                FocusScope.of(context).requestFocus(sixthFocus);
              },
            ),
          ),
          Flexible(
            child: TextFormField(
              enableInteractiveSelection: true,
              focusNode: sixthFocus,
              decoration: InputDecoration(
                hintText: 'Homo sapiens',
                labelStyle: TextStyle(fontFamily: 'SamsungOne'),
                labelText: 'Species',
              ),
              validator: (value) =>
                  value.isEmpty ? 'Date of Birth is required' : null,
              onSaved: (value) => _species = value,
            ),
          ),
        ],
      ),
    );
  }

  Widget _showGsidInput() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.white, offset: Offset(2, 0), blurRadius: 5)
          ]),
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
      child: TextFormField(
        focusNode: thirdForcus,
        enableInteractiveSelection: true,
        maxLength: 9,
        keyboardType: TextInputType.number,
        cursorColor: Colors.deepOrangeAccent,
        maxLines: 1,
        decoration: InputDecoration(
          labelStyle: TextStyle(fontFamily: 'SamsungOne'),
          labelText: 'Global Security ID',
        ),
        validator: (value) =>
            value.isEmpty ? 'Global Security ID is required' : null,
        onSaved: (value) => _gsid = num.parse(value),
        onFieldSubmitted: (value) {
          FocusScope.of(context).requestFocus(fourthFocus);
        },
      ),
    );
  }

  Widget _showReasonForVisit() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.white, offset: Offset(2, 0), blurRadius: 5)
          ]),
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
      child: Container(
        child: DropdownButton<String>(
            isExpanded: true,
            value: tourist,
            hint: Text(_reason),
            items: [
              DropdownMenuItem<String>(
                value: 'Tourist',
                child: Text(tourist),
              ),
              DropdownMenuItem<String>(
                value: 'Business',
                child: Text(business),
              ),
              DropdownMenuItem<String>(
                value: 'Family',
                child: Text(family),
              ),
              DropdownMenuItem<String>(
                value: 'Asylum',
                child: Text(asylum),
              ),
              DropdownMenuItem<String>(
                value: 'Immigration',
                child: Text(immigration),
              ),
            ],
            onChanged: (value) {
              setState(() {
                tourist = value;
                _reason = value;
              });
            }),
      ),
    );
  }

  Widget _showCancelButton() {
    return FlatButton(
        child: Text(
          'Cancel Application',
          style: TextStyle(decoration: TextDecoration.underline, color: Colors.white, shadows: [Shadow(color: Colors.white, blurRadius: 20, offset: Offset(3, 4))]),
          textAlign: TextAlign.center,
        ),
        onPressed: () {
          _onCancel();
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext) => RootPage(auth: widget.auth)));
        });
  }

  void _onCancel() async {
    try {
      widget.auth.deleteAccount();
    } catch (e) {
      print(e);
    }
  }
}

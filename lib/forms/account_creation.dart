import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:project_martian/models/planet_data.dart';

import '../services/auth_service.dart';
import '../services/authentication_check.dart';
import '../models/new_user.dart';
import '../models/finance_data.dart';

class CreateAccountPage extends StatefulWidget {
  final String userId; //Holds userId
  final BaseAuth auth; //Holds user authorization status
  final String email; //Holds user email
  final VoidCallback onCancel; //Redundant at the moment

  CreateAccountPage({this.userId, this.auth, this.email, this.onCancel});

  @override
  State<StatefulWidget> createState() {
    return _CreateAccountPageState();
  }
}

class _CreateAccountPageState extends State<CreateAccountPage> {
  final _formKey = GlobalKey<FormState>();
  PlanetData planetData;
  User user;
  Finance finance;
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
      body: _showBody(),
    );
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
      finance = Finance(userId: widget.userId, name: '$_firstName $_lastName');
      finance.createNewFinanceAccount();
      planetData = PlanetData(
          planetName: 'Mars',
          userId: widget.userId,
          planetLastName: _lastName,
          planetFirstName: _firstName,
          idType: 'Visitor',
          planetaryId: _gsid.toString(),
          flyingLicense: 'Yes',
          dateOfExpiration: '04/05/3010',
          dateIssued: '05/02/2900',
          criminalRecord: 'No',
          accessLevel: '1');
      planetData.saveInfo();
      user = User(
          //Submits all the value to the database
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
          //User is the logged in sent to home page by the RootPage
          context,
          MaterialPageRoute(
              builder: (BuildContext) => CheckAuthentication(
                    auth: widget.auth,
                  )));
    }
  }

  //Body determines the. Can be rearranged here to rearrange the whole UI
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

  //Terms and condition automatically accepted when clicked done
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
          border: InputBorder.none,
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
          border: InputBorder.none,
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

  //Gets user's birth planet
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
          border: InputBorder.none,
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

  //Three connected queries that collect tertiary user info  - DOB, Gender and Species. Application decision isn't affected by this.
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
            //So that all the field take up the entire container
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
                      minTime: DateTime(2800, 3, 5), //Maximum age 210
                      maxTime: DateTime(3010, 6, 7), onConfirm: (date) {
                    setState(() {
                      _dateOfBirth =
                          '${date.month}/${date.day}/${date.year}'; //The format at which DOB is submitted to the database as well as output to the user
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
                border: InputBorder.none,
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
                border: InputBorder.none,
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

  //GSID is the new ID system for the milkyway galaxy. Every citizen of this galaxy has one.
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
        maxLength: 9,
        //Max 9 digits
        keyboardType: TextInputType.number,
        //Only numbers can be input
        cursorColor: Colors.deepOrangeAccent,
        maxLines: 1,
        decoration: InputDecoration(
          border: InputBorder.none,
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
                tourist = value; //State changed to update dropdown box value
                _reason = value;
              });
            }),
      ),
    );
  }

  //Cancel button
  Widget _showCancelButton() {
    return FlatButton(
        child: Text(
          'Cancel Application',
          style: TextStyle(
              decoration: TextDecoration.underline,
              color: Colors.white,
              shadows: [
                Shadow(
                    color: Colors.white, blurRadius: 20, offset: Offset(3, 4))
              ]),
          textAlign: TextAlign.center,
        ),
        onPressed: () {
          _onCancel();
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext) => CheckAuthentication(
                      auth: widget
                          .auth))); //Redirects to root page to figure out authorization status
        });
  }

  //On cancel, user account is deleted from the database
  void _onCancel() async {
    try {
      widget.auth.deleteAccount();
    } catch (e) {
      print(e);
    }
  }
}

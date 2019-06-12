import 'package:flutter/material.dart';
import 'package:project_martian/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:project_martian/models/user_data.dart';
import 'package:flushbar/flushbar.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:math';

import 'forms/id_form.dart';
import 'models/planet_data.dart';
import 'services/authentication_check.dart';
import 'models/finance_data.dart';
import 'package:project_martian/widgets/bank_card.dart';
import 'widgets/id_card.dart';
import 'widgets/email_verification.dart';
import 'widgets/header.dart';
import 'bank.dart';

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

enum DataStatus { NOT_DETERMINED, DETERMINED }

class _HomePageState extends State<HomePage> {
  UserData userData;
  Finance finance;
  String userId,
      firstName = '',
      lastName,
      mother_planet,
      dateOfBirth,
      species,
      reason,
      email,
      gender;
  num gsid;
  String balance;
  bool martian;
  int numOfIds;
  DataStatus dataStatus = DataStatus.NOT_DETERMINED;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          dataStatus == DataStatus.NOT_DETERMINED ? 'Loading...' : '$firstName $lastName',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[_showLogOutButton()],
      ),
      body: dataStatus == DataStatus.NOT_DETERMINED
          ? _showLoadingScreen()
          : _showBody(),
    );
  }

  @override
  void initState() {
    super.initState();
    //Gets ID data from user
    Firestore.instance
        .collection('users')
        .document(widget.userId)
        .get()
        .then((data) {
      setState(() {
        if (data.exists) {
          Firestore.instance
              .collection('users')
              .document(widget.userId)
              .collection('planetary_ids')
              .getDocuments()
              .then((value) {
            setState(() {
              dataStatus = data == null || value == null
                  ? DataStatus.NOT_DETERMINED
                  : DataStatus.DETERMINED;
            });
          });

          //Gets user primary data
          fetchData(data);
        }
      });
    });

    //get financial data from User's database
    finance = Finance(userId: widget.userId);
    finance.getBalance().then((value) {
      setState(() {
        dataStatus = value == null ? DataStatus.NOT_DETERMINED : DataStatus.DETERMINED;
        if(value != null) {
          balance = value.toStringAsFixed(2);
          print(balance);
        }
      });
    });
  }

  void fetchData(DocumentSnapshot data) {
    firstName = data.data['firstName'];
    lastName = data.data['lastName'];
    dateOfBirth = data.data['dateOfBirth'];
    gender = data.data['gender'];
    gsid = data.data['gsid'];
    mother_planet = data.data['mother_planet'];
    reason = data.data['reason'];
    species = data.data['species'];
    userId = data.data['userId'];
    email = data.data['email'];
    martian = data.data['martian'];
  }

  Widget _showLoadingScreen() {
    return Scaffold(
      body: Center(
          child: SpinKitThreeBounce(
        color: Colors.deepOrangeAccent,
        duration: Duration(seconds: 3),
      )),
    );
  }

  Widget _showBody() {
    return ListView(children: <Widget>[
      _showUnverifiedEmailNotification(),
      Header(text: 'Planetary IDs'),
      _showIdCards(),
      Header(text: 'Finance'),
      _showBankCard(),
    ]);
  }

  Widget _showUnverifiedEmailNotification() {
    return VerifyEmail(auth: widget.auth,);
  }

  Widget _showLogOutButton() {
    return FlatButton(
        child: Text(
          'Logout',
          style: TextStyle(color: Colors.white),
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

  Widget _showIdCards(){
    return IdCard(userId: widget.userId, auth: widget.auth);
  }

  Widget _showBankCard() {
    return InkWell(onTap: () {
      Navigator.push(context, MaterialPageRoute(builder: (BuildContext) => Bank(balance: balance,)));
    },child: BankCard(balance: balance,));
  }
}

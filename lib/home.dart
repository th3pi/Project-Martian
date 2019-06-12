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

  PageController pageController;
  int currentPage = 2;
  double page = 2.0;
  double scaleFraction = 0.7,
      fullScale = 1.0,
      pagerHeight = 200,
      viewportFraction = 0.95;

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
  List<Map<String, dynamic>> listOfIds = [];

  String _errorMessage = 'Resending Verification Email',
      _errorDetails =
          'Please check your inbox - LOG OUT and LOG BACK IN to activate your account';
  DataStatus dataStatus = DataStatus.NOT_DETERMINED;
  bool _status;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          '$firstName $lastName',
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

    //Initializes the ID cards carousel
    pageController =
        PageController(initialPage: currentPage, viewportFraction: viewportFraction);

    //Shows email notification if email not verified
    widget.auth.isEmailVerified().then((value) {
      setState(() {
        if (value != null) {
          _status = value;
        }
      });
    });

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

    //Gets a list of ids
    Firestore.instance
        .collection('users')
        .document(widget.userId)
        .collection('planetary_ids')
        .snapshots()
        .listen((snapshot) {
      snapshot.documents.forEach((doc) {
        listOfIds.add(doc.data);
        setState(() {
          numOfIds = listOfIds.length+1;
          currentPage = 0;
        });
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
      _showHeader('Planetary IDs'),
      _showIdCards(),
      _showHeader('Finance'),
      _showBankCard(),
    ]);
  }

  Widget _showUnverifiedEmailNotification() {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 0),
      decoration: BoxDecoration(color: Colors.red),
      height: !_status ? 85 : 0,
      child: Column(
        children: <Widget>[
          Center(
            child: Text(
              'Email not verified - Banking, Comms and Social Feed disabled',
              style: TextStyle(color: Colors.white),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                onPressed: () {
                  _showVerificationEmailNotification();
                  _sendEmailVerification();
                },
                child: Text(
                  'Resend Verification',
                  style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.underline),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  void _showVerificationEmailNotification() {
    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      isDismissible: true,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticOut,
      icon: Icon(
        Icons.info_outline,
        color: Colors.white,
      ),
      backgroundColor: Colors.black87,
      flushbarStyle: FlushbarStyle.FLOATING,
      borderRadius: 3,
      aroundPadding: EdgeInsets.all(15),
      showProgressIndicator: true,
      boxShadows: [
        BoxShadow(
          color: Colors.black26,
          offset: Offset(0.0, 2.0),
          blurRadius: 3.0,
        )
      ],
      titleText: Text(
        _errorMessage,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      messageText: Text(
        _errorDetails,
        style: TextStyle(color: Colors.white),
      ),
      duration: Duration(seconds: 6),
    ).show(context);
  }

  void _sendEmailVerification() async {
    await widget.auth.sendEmailVerification();
  }

  Widget _showHeader(String text) {
    return Column(
      children: <Widget>[
        Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.fromLTRB(10, 10, 0, 5),
            child: Text(
              text,
              style: TextStyle(
                  fontSize: 25,
                  color: Colors.deepOrangeAccent,
                  fontFamily: 'SamsungOne',
                  fontWeight: FontWeight.bold),
            )),
        Divider(
          color: Colors.black12,
        ),
      ],
    );
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
    return BankCard(balance: balance,);
  }
}

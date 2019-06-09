import 'package:flutter/material.dart';
import 'package:project_martian/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:project_martian/models/user_data.dart';
import 'package:flushbar/flushbar.dart';
import 'dart:math';

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

  PageController pageController;
  int currentPage = 1;
  double page = 2.0;
  double scaleFraction = 0.7,
      fullScale = 1.0,
      pagerHeight = 200,
      viewportFraction = 0.5;

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
        centerTitle: true,
        title: Text(firstName),
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
    pageController =
        PageController(initialPage: 1, viewportFraction: viewportFraction);
    widget.auth.isEmailVerified().then((value) {
      setState(() {
        dataStatus =
            value == null ? DataStatus.NOT_DETERMINED : DataStatus.DETERMINED;
        if (value != null) {
          _status = value;
        }
      });
    });
    Firestore.instance
        .collection('users')
        .document(widget.userId)
        .get()
        .then((data) {
      setState(() {
        dataStatus =
            data == null ? DataStatus.NOT_DETERMINED : DataStatus.DETERMINED;
        if (data.exists) {
          fetchData(data);
        }
      });
    });
  }

  void fetchData(DocumentSnapshot data) {
    userData = UserData(widget.userId);
    firstName = data.data['firstName'];
    lastName = data.data['lastName'];
    dateOfBirth = data.data['dateOfBirth'];
    gender = data.data['gender'];
    mother_planet = data.data['mother_planet'];
    reason = data.data['reason'];
    species = data.data['species'];
    userId = data.data['userId'];
    email = data.data['email'];
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
      _showLogo(),
      _showIdCards()
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

  Widget _showLogo() {
    return Hero(
        tag: 'marsLogo',
        child: Container(
            alignment: Alignment.topCenter,
            padding: EdgeInsets.fromLTRB(0, 30, 0, 50),
            child: Text(
              firstName,
              style: TextStyle(
                  fontSize: 50,
                  color: Colors.deepOrangeAccent,
                  fontFamily: 'SamsungOne',
                  fontWeight: FontWeight.bold),
            )));
  }

  Widget _showLogOutButton() {
    print(_status);
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

  Widget _idCards(double scale) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: pagerHeight * scale,
        width: pagerHeight * scale,
        child: Card(
          elevation: 5,
          clipBehavior: Clip.antiAlias,
          child: Text(firstName),
        ),
      ),
    );
  }

  Widget _showIdCards() {
    return Container(
      height: 400,
      child: ListView(
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Container(
            height: pagerHeight,
            child: NotificationListener<ScrollNotification>(
              child: PageView.builder(
                itemBuilder: (context, index) {
                  final scale = max(scaleFraction,
                      (fullScale - (index - page).abs()) + viewportFraction);
                  return _idCards(scale);
                },
                itemCount: 3,
                controller: pageController,
                onPageChanged: (pos) {
                  setState(() {
                    currentPage = pos;
                  });
                },
                physics: BouncingScrollPhysics(),
              ),
              onNotification: (ScrollNotification notification) {
                if (notification is ScrollUpdateNotification) {
                  setState(() {
                    page = pageController.page;
                  });
                }
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20),
            child: Text(dateOfBirth),
          )
//          Container(
//            height: 200,
//            width: 200,
//            child: Card(
//              elevation: 4,
//              clipBehavior: Clip.antiAlias,
//              shape: RoundedRectangleBorder(
//                  borderRadius: BorderRadius.circular(20)),
//              child: Text(firstName),
//            ),
//          ),
//          Container(
//            height: 200,
//            width: 200,
//            child: Card(
//              elevation: 4,
//              clipBehavior: Clip.antiAlias,
//              shape: RoundedRectangleBorder(
//                  borderRadius: BorderRadius.circular(20)),
//              child: Text(firstName),
//            ),
//          ),
//          Container(
//            height: 200,
//            width: 200,
//            child: Card(
//              elevation: 4,
//              clipBehavior: Clip.antiAlias,
//              shape: RoundedRectangleBorder(
//                  borderRadius: BorderRadius.circular(20)),
//              child: Text(firstName),
//            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:project_martian/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:project_martian/models/user_data.dart';
import 'package:flushbar/flushbar.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:math';

import 'forms/id_form.dart';

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
  bool martian;
  int numOfIds;
  List listOfIds;

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
          Firestore.instance.collection('users').document(widget.userId).collection('planetary_ids').getDocuments().then((value) {
            setState(() {
              numOfIds = value.documents.length+1;
            });
          });
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

  Widget _showHeader(String text) {
    return Column(
      children: <Widget>[
        Hero(
            tag: 'marsLogo',
            child: Container(
                alignment: Alignment.topLeft,
                padding: EdgeInsets.fromLTRB(10, 10, 0, 5),
                child: Text(
                  text,
                  style: TextStyle(
                      fontSize: 25,
                      color: Colors.deepOrangeAccent,
                      fontFamily: 'SamsungOne',
                      fontWeight: FontWeight.bold),
                ))),
        Divider(
          color: Colors.black54,
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

  Widget _idCards(double scale) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.only(bottom: 20),
        height: pagerHeight * scale,
        width: 800,
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          clipBehavior: Clip.antiAlias,
          child: Container(
            child: Row(
              children: <Widget>[
                Flexible(
                  flex: 2,
                  child: Container(
                    child: QrImage(
                      data: userId,
                      size: 180,
                    ),
                  ),
                ),
                Flexible(
                  flex: 2,
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                                padding: EdgeInsets.fromLTRB(0, 15, 0, 5),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      'First Name',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    Container(
                                      child: Text(
                                        firstName,
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                )),
                            Container(
                                padding: EdgeInsets.fromLTRB(20, 15, 0, 5),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      'Last Name',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    Container(
                                      child: Text(
                                        lastName,
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                )),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Container(
                                padding: EdgeInsets.fromLTRB(0, 15, 0, 5),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      'Planetary ID',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    Container(
                                      child: Text(
                                        gsid.toString(),
                                        //TODO: Change this to planetary ID.
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                )),
                            Container(
                                padding: EdgeInsets.fromLTRB(20, 15, 0, 5),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      'Planet Name',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    Container(
                                      alignment: Alignment.centerRight,
                                      padding: EdgeInsets.only(left: 5),
                                      child: Text(
                                        mother_planet,
                                        //TODO: Change this specific planet name
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                )),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Container(
                                padding: EdgeInsets.fromLTRB(0, 15, 0, 5),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      'ID Type',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    Container(
                                      child: Text(
                                        martian ? 'Citizen' : 'Visitor',
                                        //TODO: Change this to specific planet ID type.
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                )),
                            Container(
                                padding: EdgeInsets.fromLTRB(20, 15, 0, 5),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      'Date of Expiration',
                                      style: TextStyle(fontSize: 10),
                                    ),
                                    Container(
                                      padding: EdgeInsets.only(left: 5),
                                      child: Text(
                                        dateOfBirth,
                                        //TODO: Change this specific planet id expiration date
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _showAddIdCard(double scale) {
    return InkWell(
      splashColor: Colors.deepOrangeAccent,
      onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext) => IdForm(userId: widget.userId, auth: widget.auth,))),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: EdgeInsets.only(bottom: 20),
          height: pagerHeight * scale,
          width: 800,
          child: Card(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 10,
            clipBehavior: Clip.antiAlias,
            child: Center(child: Icon(Icons.add_circle_outline, size: 50,),),
          ),
        ),
      ),
    );
  }

  Widget _showIdCards() {
    return Container(
      height: 400,
      child: ListView(
        children: <Widget>[
          Container(
            height: pagerHeight,
            child: NotificationListener<ScrollNotification>(
              child: PageView.builder(
                itemBuilder: (context, index) {
                  final scale = max(scaleFraction,
                      (fullScale - (index - page).abs()) + viewportFraction);
                  return index == 0 ? _showAddIdCard(scale) : _idCards(scale);
                },
                itemCount: numOfIds,
                controller: pageController,
                onPageChanged: (pos) {
                  setState(() {
                    currentPage = pos;
                  });
                },
                physics: AlwaysScrollableScrollPhysics(),
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
        ],
      ),
    );
  }
}

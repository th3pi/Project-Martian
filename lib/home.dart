import 'package:flutter/material.dart';
import 'package:project_martian/services/auth_service.dart';
import 'package:swipedetector/swipedetector.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:animator/animator.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import 'services/authentication_check.dart';
import 'models/user_data.dart';
import 'models/finance_data.dart';
import 'package:project_martian/widgets/bank_page/bank_card.dart';
import 'widgets/id_card_carousel.dart';
import 'widgets/email_verification.dart';
import 'widgets/header.dart';
import 'bank.dart';
import 'profile.dart';
import 'comms.dart';

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

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  Animation animation, delayedAnimation, muchDelayedAnimation;
  AnimationController animationController;

  final FirebaseMessaging _messaging = FirebaseMessaging();
  User user;
  Finance finance;
  String token;
  int numOfIds;
  double myOpacity = 0;
  Map<String, dynamic> userData;
  DataStatus dataStatus = DataStatus.NOT_DETERMINED;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.deepOrange),
              child: Container(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Text(
                          dataStatus == DataStatus.NOT_DETERMINED
                              ? 'Loading...'
                              : '${userData['firstName']} ${userData['lastName']}',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          'uMail  ',
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          dataStatus == DataStatus.NOT_DETERMINED
                              ? 'Loading...'
                              : '${userData['email']}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          'GSID  ',
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          dataStatus == DataStatus.NOT_DETERMINED
                              ? 'Loading...'
                              : '${userData['gsid']}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          'From  ',
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          dataStatus == DataStatus.NOT_DETERMINED
                              ? 'Loading...'
                              : '${userData['mother_planet']}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          'DOB  ',
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          dataStatus == DataStatus.NOT_DETERMINED
                              ? 'Loading...'
                              : '${userData['dateOfBirth']}',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            ListTile(
              title: RaisedButton(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Row(
                    children: <Widget>[
                      Icon(MdiIcons.accountCardDetailsOutline, size: 15),
                      SizedBox(
                        width: 15,
                      ),
                      Text('My Martian Account'),
                    ],
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext) => Profile(
                                email: widget.email,
                                auth: widget.auth,
                              )));
                },
              ),
            ),
            ListTile(
              title: RaisedButton(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Row(
                    children: <Widget>[
                      Icon(MdiIcons.bank, size: 15),
                      SizedBox(
                        width: 15,
                      ),
                      Text('Bank'),
                    ],
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext) => Bank(
                                email: widget.email,
                              )));
                },
              ),
            ),
            ListTile(
              title: RaisedButton(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.chat_bubble_outline, size: 15),
                      SizedBox(
                        width: 15,
                      ),
                      Text('Comms'),
                    ],
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext) => Comms(
                                email: widget.email,
                                auth: widget.auth,
                              )));
                },
              ),
            ),
            ListTile(
              title: RaisedButton(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Row(
                    children: <Widget>[
                      Icon(MdiIcons.logout, size: 15,),
                      SizedBox(
                        width: 15,
                      ),
                      Text('Logout'),
                    ],
                  ),
                ),
                onPressed: () {
                  _signOut();
                },
              ),
            )
          ],
        ),
      ),
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          dataStatus == DataStatus.NOT_DETERMINED
              ? 'Loading...'
              : '${userData['firstName']} ${userData['lastName']}',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[_showLogOutButton()],
      ),
      body: _showBody(),
    );
  }

  @override
  void initState() {
    super.initState();
    _messaging.getToken().then((token) {
      print(token);
      setState(() {
        this.token = token;
      });
    });
    _messaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message ${message['data']['message']}');
      },
      onResume: (Map<String, dynamic> message) async {
        if (message['data']['message'] == 'receive') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext) => Bank(
                        email: widget.email,
                      )));
        }
      },
      onLaunch: (Map<String, dynamic> message) async {
        if (message['data']['message'] == 'receive') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext) => Bank(
                        email: widget.email,
                      )));
        }
      },
    );
    user = User(email: widget.email);
    user.getAllData().then((data) {
      setState(() {
        if (data != null) {
          dataStatus = DataStatus.DETERMINED;
          userData = data;
          user.addField('tokenId', token);
        }
      });
    });
  }

  Widget _showBody() {
    return ListView(children: <Widget>[
      _showUnverifiedEmailNotification(),
      Header(text: 'Passports'),
      _showIdCards(),
      Header(text: 'Finance'),
      _showBankCard(),
    ]);
  }

  Widget _showUnverifiedEmailNotification() {
    return VerifyEmail(
      auth: widget.auth,
    );
  }

  Widget _showLogOutButton() {
    return FlatButton(
        child: Text(
          'Logout',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          _signOut();
        });
  }

  void _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext) => CheckAuthentication(
                    auth: widget.auth,
                    userId: widget.email,
                  )));
    } catch (e) {
      print(e);
    }
  }

  Widget _showIdCards() {
    return IdCardCarousel(email: widget.email, auth: widget.auth);
  }

  Widget _showBankCard() {
    return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (BuildContext) => Bank(
                        email: widget.email,
                      )));
        },
        child: SwipeDetector(
          onSwipeUp: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext) => Bank(
                          email: widget.email,
                        )));
          },
          child: BankCard(
            auth: widget.auth,
            email: widget.email,
          ),
        ));
  }
}

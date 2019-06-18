import 'package:flutter/material.dart';
import 'package:project_martian/services/auth_service.dart';
import 'package:swipedetector/swipedetector.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'models/user_data.dart';
import 'models/finance_data.dart';
import 'package:project_martian/widgets/bank_page/bank_card.dart';
import 'widgets/id_card.dart';
import 'widgets/email_verification.dart';
import 'widgets/header.dart';
import 'bank.dart';
import 'profile.dart';

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
  final FirebaseMessaging _messaging = FirebaseMessaging();
  User user;
  Finance finance;
  String token;
  int numOfIds;
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
              title: Card(
                elevation: 20,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.person),
                      SizedBox(
                        width: 20,
                      ),
                      Text('My Martian Account'),
                    ],
                  ),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext) => Profile(
                          email: widget.email, auth: widget.auth,
                        )));
              },
            ),
            ListTile(
              title: Card(                elevation: 20,

                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.attach_money),
                      SizedBox(
                        width: 20,
                      ),
                      Text('Bank'),
                    ],
                  ),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext) => Bank(
                              email: widget.email,
                            )));
              },
            ),
            ListTile(
              title: Card(                elevation: 20,

                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Container(
                  padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.power_settings_new),
                      SizedBox(
                        width: 20,
                      ),
                      Text('Logout'),
                    ],
                  ),
                ),
              ),
              onTap: () {
                _signOut();
              },
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
    _messaging.getToken().then((token){
      setState(() {
        this.token = token;
      });
    });
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
      Header(text: 'Planetary IDs'),
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
    } catch (e) {
      print(e);
    }
  }

  Widget _showIdCards() {
    return IdCard(email: widget.email, auth: widget.auth);
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
            email: widget.email,
          ),
        ));
  }
}

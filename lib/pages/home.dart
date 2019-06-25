import 'package:flutter/material.dart';
import 'package:project_martian/services/auth_service.dart';
import 'package:swipedetector/swipedetector.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../services/authentication_check.dart';
import '../models/user_data.dart';
import '../models/finance_data.dart';
import 'package:project_martian/widgets/bank_page/bank_card.dart';
import '../widgets/id_card_carousel.dart';
import '../widgets/email_verification.dart';
import '../widgets/header.dart';
import 'package:project_martian/pages/bank/bank.dart';
import 'package:project_martian/pages/profile/profile.dart';
import 'comms/comms.dart';
import '../widgets/drawer.dart';

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
      drawer: CustomDrawer(email: widget.email, auth: widget.auth,),
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
                    auth: widget.auth,
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
                    auth: widget.auth,
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
                    auth: widget.auth,
                      )));
        },
        child: SwipeDetector(
          onSwipeUp: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (BuildContext) => Bank(
                          email: widget.email,
                      auth: widget.auth,
                        )));
          },
          child: BankCard(
            auth: widget.auth,
            email: widget.email,
          ),
        ));
  }
}

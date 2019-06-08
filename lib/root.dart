import 'package:flutter/material.dart';
import 'package:project_martian/services/auth_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/scheduler.dart';
import 'package:after_layout/after_layout.dart';

import 'auth.dart';
import 'home.dart';

class RootPage extends StatefulWidget {
  final BaseAuth auth;
  final String userId;
  RootPage({this.auth, this.userId});

  @override
  State<StatefulWidget> createState() {
    return _RootPageState();
  }
}

enum AuthStatus { NOT_DETERMINED, NOT_LOGGED_IN, LOGGED_IN }

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String _userId = '';
  String _email = '';

  @override
  Widget build(BuildContext context) {
    switch (authStatus) {
      case AuthStatus.NOT_DETERMINED:
        return _showLoadingScreen();
        break;
      case AuthStatus.NOT_LOGGED_IN:
        return UserOnBoarding(
          auth: widget.auth,
          onSignedIn: _onLoggedIn,
          onCancel: _onSignedOut,
        );
        break;
      case AuthStatus.LOGGED_IN:
        if (_userId.length > 0 && _userId != null) {
          return HomePage(
            userId: _userId,
            auth: widget.auth,
            onSignedOut: _onSignedOut,
            email: _email,
          );
        } else {
          return _showLoadingScreen();
        }
        break;
      default:
        return _showLoadingScreen();
    }
  }

  @override
  void initState() {
    super.initState();
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        if (user != null) {
          _userId = user?.uid;
          _email = user?.email.toString();
        }
        authStatus =
            user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
      });
    });
  }

//  void _determineAuthStatus() async {
//    FirebaseUser user = await widget.auth.getCurrentUser();
//    if(user != null){
//      _userId = user?.uid;
//      _email = user?.email.toString();
//    }
//    if(user?.uid == null){
//      authStatus = AuthStatus.NOT_LOGGED_IN;
//    }else{
//      authStatus = AuthStatus.LOGGED_IN;
//    }
//  }

  void _onLoggedIn() {
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userId = user?.uid.toString();
        _email = user?.email.toString();
      });
    });
    setState(() {
      authStatus = AuthStatus.LOGGED_IN;
    });
  }

  void _onSignedOut() {
    if(this.mounted) {
      setState(() {
        authStatus = AuthStatus.NOT_LOGGED_IN;
      });
    }
  }

  Widget _showLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.deepOrange,
      body: Center(child: SpinKitCubeGrid(color: Colors.white)),
    );
  }
}

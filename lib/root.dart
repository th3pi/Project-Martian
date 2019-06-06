import 'package:flutter/material.dart';
import 'auth.dart';
import 'package:project_martian/services/auth_service.dart';
import 'home.dart';

class RootPage extends StatefulWidget {
  final BaseAuth auth;

  RootPage({this.auth});

  @override
  State<StatefulWidget> createState() {
    return _RootPageState();
  }
}

enum AuthStatus { NOT_DETERMINED, NOT_LOGGED_IN, LOGGED_IN }

class _RootPageState extends State<RootPage> {
  AuthStatus authStatus = AuthStatus.NOT_DETERMINED;
  String _userId = '';

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
        );
        break;
      case AuthStatus.LOGGED_IN:
        if (_userId.length > 0 && _userId != null) {
          return HomePage(
              userId: _userId,
              auth: widget.auth,
              onSignedOut: _onSignedOut);
        }else{
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
        }
        authStatus =
            user?.uid == null ? AuthStatus.NOT_LOGGED_IN : AuthStatus.LOGGED_IN;
      });
    });
  }

  void _onLoggedIn() {
    widget.auth.getCurrentUser().then((user) {
      setState(() {
        _userId = user?.uid.toString();
      });
    });
    setState(() {
      authStatus = AuthStatus.LOGGED_IN;
    });
  }

  void _onSignedOut() {
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
    });
  }

  Widget _showLoadingScreen() {
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: LinearProgressIndicator(),
      ),
    );
  }
}

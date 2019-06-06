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
        );
        break;
      case AuthStatus.LOGGED_IN:
        if (_userId.length > 0 && _userId != null) {
          return HomePage(
              userId: _userId, auth: widget.auth, onSignedOut: _onSignedOut, email: _email,);
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
    setState(() {
      authStatus = AuthStatus.NOT_LOGGED_IN;
    });
  }

  Widget _showLoadingScreen() {
    return Scaffold(
      backgroundColor: Colors.deepOrange,
      body: Center(
        child: Hero(
            tag: 'marsLogo',
            child: Text(
              'Martian',
              style: TextStyle(
                  fontSize: 80,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            )),
      ),
    );
  }
}
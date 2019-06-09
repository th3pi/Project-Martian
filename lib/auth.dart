import 'package:flutter/material.dart';
import 'package:project_martian/services/auth_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flushbar/flushbar.dart';

import 'package:project_martian/forms/account_creation.dart';

class UserOnBoarding extends StatefulWidget {
  final BaseAuth auth;
  final VoidCallback onSignedIn;
  final VoidCallback onCancel;

  UserOnBoarding({this.auth, this.onSignedIn, this.onCancel});

  @override
  State<StatefulWidget> createState() {
    return _UserOnBoardingState();
  }
}

enum FormMode { LOGIN, SIGNUP }

class _UserOnBoardingState extends State<UserOnBoarding> {
  final _formKey = GlobalKey<FormState>(); // Manages form state
  String _errorMessage = ''; //Error message that pops up above email field
  String _email, _password;
  FocusNode secondNode = FocusNode(); //To change form focus
  FormMode _formMode = FormMode.SIGNUP; //Form mode initialized to login
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepOrange,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          'Onboarding',
          style: (TextStyle(
              color: Colors.deepOrangeAccent,
              fontFamily: 'SamsungOne',
              fontWeight: FontWeight.bold)),
        ),
      ),
      body: Stack(
        children: <Widget>[
          _showBody(),
          _showCircularProgress()
        ], //_showBody  manages the UI
      ),
    );
  }

  //Page initialized with no error message and no loading
  @override
  void initState() {
    super.initState();
    _errorMessage = '';
    _isLoading = false;
  }

  //Loading icon
  Widget _showCircularProgress() {
    if (_isLoading) {
      return Container(
        alignment: Alignment.topCenter,
        child: SpinKitThreeBounce(
          size: 50,
          color: Colors.white,
        ),
      );
    }
    return Container();
  }

  //Scrollable body. Rearrange children order to rearrange UI.
  Widget _showBody() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: false,
          children: <Widget>[
            _showLogo(),
            _showErrorMessage(),
            _showEmailInput(),
            _showPasswordInput(),
            _showPrimaryButton(),
            _showSecondaryButton(),
          ],
        ),
      ),
    );
  }

  Widget _showLogo() {
    return Hero(
      tag: 'marsLogo',
      child: Center(
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 70, 0, 50),
          child: Text(
            'Martian',
            style: TextStyle(
                fontSize: 50,
                color: Colors.white,
                fontFamily: 'SamsungOne',
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _showEmailInput() {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.white, offset: Offset(2, 0), blurRadius: 5)
          ]),
      margin: const EdgeInsets.fromLTRB(0, 20, 0, 0),
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
      child: TextFormField(
        cursorColor: Colors.deepOrangeAccent,
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: InputDecoration(labelText: 'Email'),
        validator: (String value) =>
            value.isEmpty ? 'Email can\'t be empty' : null,
        //Doesn't let user submit empty field
        onFieldSubmitted: (value) {
          FocusScope.of(context).requestFocus(secondNode);
        },
        onSaved: (value) {
          _email = value;
        },
      ),
    );
  }

  Widget _showPasswordInput() {
    bool _showPassword = false;
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(color: Colors.white, offset: Offset(2, 0), blurRadius: 5)
          ]),
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
      child: TextFormField(
        cursorColor: Colors.deepOrangeAccent,
        maxLines: 1,
        obscureText: true,
        focusNode: secondNode,
        decoration: InputDecoration(
          labelStyle: TextStyle(fontFamily: 'SamsungOne'),
          labelText: 'Password',
        ),
        validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
        onSaved: (value) => _password = value,
      ),
    );
  }

  ///Create account button
  ///Button changes depending form type

  Widget _showPrimaryButton() {
    return Container(
      margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
      child: RaisedButton(
        padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        splashColor: Colors.orangeAccent,
        elevation: 5,
        color: Colors.white,
        child: _formMode == FormMode.LOGIN
            ? Text(
                'Login',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.deepOrangeAccent),
              )
            : Text(
                'Get Visitor Pass',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.deepOrangeAccent,
                    fontFamily: 'SamsungOne'),
              ),
        onPressed: _validateAndSubmit,
      ),
    );
  }

  ///Form Type Change Button

  Widget _showSecondaryButton() {
    return FlatButton(
      splashColor: Colors.white,
      child: _formMode == FormMode.LOGIN
          ? Text(
              'Not a Martian? Get visitor pass',
              style: TextStyle(
                  color: Colors.white, decoration: TextDecoration.underline),
            )
          : Text('Are you a Martian? Sign in',
              style: TextStyle(
                  color: Colors.white, decoration: TextDecoration.underline)),
      onPressed: () {
        if (_formMode == FormMode.LOGIN) {
          _changeFormToSignUp();
        } else {
          _changeFormToLogin();
        }
      },
    );
  }

  ///Changes for state to sign up mode

  void _changeFormToSignUp() {
//    _formKey.currentState.reset();
    _errorMessage = '';
    setState(() {
      _formMode = FormMode.SIGNUP;
    });
  }

  ///Changes form state to login mode

  void _changeFormToLogin() {
//    _formKey.currentState.reset();
    _errorMessage = '';
    setState(() {
      _formMode = FormMode.LOGIN;
    });
  }

  //Animated error message
  Widget _showErrorMessage() {
    return AnimatedOpacity(
      curve: Curves.bounceInOut,
      duration: Duration(milliseconds: 600),
      opacity: _errorMessage.length > 0 ? 1.0 : 0.0,
      //This widget pops up if error message gets a value
      child: Center(
        child: Text(
          _errorMessage,
          style: TextStyle(
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
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
      backgroundColor: Colors.green,
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
        'Opening application form...',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      messageText: Text(
        'An email verification request has been sent. Martian Port Authority only processes verified applicants.',
        style: TextStyle(color: Colors.white),
      ),
      duration: Duration(seconds: 6),
    ).show(context);
  }

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void _validateAndSubmit() async {
    setState(() {
      _errorMessage = '';
      _isLoading = true;
    });
    if (_validateAndSave()) {
      String userId = "";
      try {
        if (_formMode == FormMode.LOGIN) {
          userId = await widget.auth.signIn(_email, _password);
          print('Signed in user: $userId');
        } else {
          userId = await widget.auth.signUp(_email, _password);
          _showVerificationEmailNotification();
          widget.auth.sendEmailVerification();
          Future.delayed(Duration(seconds: 4), () {
            setState(() {
              Navigator.pushReplacement(
                  //If user doesn't exist, they are redirected to the account creation page.
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext) => CreateAccountPage(
                            userId: userId,
                            auth: widget.auth,
                            email: _email,
                            onCancel: widget.onCancel,
                          )));
            });
          });
          print('Signed up user: $userId');
        }
        setState(() {
          _isLoading = false;
        });
        if (userId != null &&
            userId.length > 0 &&
            _formMode == FormMode.LOGIN) {
          widget.onSignedIn();
          print('signed in');
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          switch (e.toString()) {
            case 'PlatformException(ERROR_USER_NOT_FOUND, There is no user record corresponding to this identifier. The user may have been deleted., null)':
              _errorMessage = 'No record of visitor pass/citizenship in our databases';
              break;
            case 'PlatformException(ERROR_WRONG_PASSWORD, The password is invalid or the user does not have a password., null)':
              _errorMessage = 'Wrong password';
              break;
            case 'PlatformException(ERROR_INVALID_EMAIL, The email address is badly formatted., null)':
              _errorMessage =
                  'Not a valid email address - double check the formatting';
              break;
            case 'PlatformException(ERROR_NETWORK_REQUEST_FAILED, A network error (such as timeout, interrupted connection or unreachable host) has occurred., null)':
              _errorMessage =
                  'Could not communicate to Mars Data Center - please check your network connection and try again';
              break;
            case 'PlatformException(ERROR_EMAIL_ALREADY_IN_USE, The email address is already in use by another account., null)':
              _errorMessage = 'You already have a visitor pass/citizenship - log in instead';
              break;
            default:
              _errorMessage =
                  'Sorry we do not know what went wrong - Check your internet connection, email and password';
              break;
          }
        });
        print('ERROR:: ${e.toString()}');
      }
    }
    setState(() {
      _isLoading = false;
    });
  }
}

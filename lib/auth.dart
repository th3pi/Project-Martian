import 'package:flutter/material.dart';
import 'package:project_martian/services/auth_service.dart';

import 'home.dart';

class UserOnBoarding extends StatefulWidget {
  final BaseAuth auth;

  UserOnBoarding({this.auth});

  @override
  State<StatefulWidget> createState() {
    return _UserOnBoardingState();
  }
}

enum FormMode { LOGIN, SIGNUP }

class _UserOnBoardingState extends State<UserOnBoarding> {
  final _formKey = GlobalKey<FormState>();
  String _errorMessage = '';
  String _email, _password;
  FocusNode secondNode = FocusNode();
  FormMode _formMode;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.deepOrange,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        title: Text(
          'Login',
          style: (TextStyle(
              color: Colors.deepOrangeAccent,
              fontFamily: 'SamsungOne',
              fontWeight: FontWeight.bold)),
        ),
      ),
      body: Stack(
        children: <Widget>[_showBody(), _showCircularProgress()],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _errorMessage = '';
    _isLoading = false;
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    }
    return Container();
  }

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
      tag: 'Hero',
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
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
      child: TextFormField(
        cursorColor: Colors.deepOrangeAccent,
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: InputDecoration(labelText: 'Email'),
        validator: (String value) =>
            value.isEmpty ? 'Email can\'t be empty' : null,
        onFieldSubmitted: (value){
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
                style: TextStyle(fontSize: 20, color: Colors.deepOrangeAccent),
              )
            : Text(
                'Create Account',
                style: TextStyle(
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
              style: TextStyle(color: Colors.white),
            )
          : Text('Are you a Martian? Sign in',
              style: TextStyle(color: Colors.white)),
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
    _formKey.currentState.reset();
    _errorMessage = '';
    setState(() {
      _formMode = FormMode.SIGNUP;
    });
  }

  ///Changes form state to login mode

  void _changeFormToLogin() {
    _formKey.currentState.reset();
    _errorMessage = '';
    setState(() {
      _formMode = FormMode.LOGIN;
    });
  }

  Widget _showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return Container(height: 20,
        child: Center(
          child: Text(
            _errorMessage,
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    } else {
      return Container(height: 20,);
    }
  }

  Widget _showVerificationEmailNotification() {
    return SnackBar(
      duration: Duration(seconds: 5),
      content: Text('Verification email sent to $_email'),
    );
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
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (BuildContext) => HomePage(_email)));
        } else {
          userId = await widget.auth.signUp(_email, _password);
          _showVerificationEmailNotification();
          widget.auth.sendEmailVerificiation();
          _changeFormToLogin();
          print('Signed up user: $userId');
        }
        setState(() {
          _isLoading = false;
        });
        if (userId != null &&
            userId.length > 0 &&
            _formMode == FormMode.LOGIN) {
          print('signed in');
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Invalid email or password';
        });
        print(e);
      }
    }
    setState(() {
      _isLoading = false;
    });
  }
}

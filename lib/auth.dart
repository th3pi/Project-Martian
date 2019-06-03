import 'package:flutter/material.dart';

class Auth extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AuthState();
  }
}

enum FormMode { LOGIN, SIGNUP }

class _AuthState extends State<Auth> {
  final _formKey = GlobalKey<FormState>();
  String _errorMessage = '';
  String _email, _password;
  FocusNode secondNode = FocusNode();
  FormMode _formMode;

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
      body: _showBody(),
    );
  }

  Widget _showBody() {
    return Container(
      padding: EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: ListView(
          shrinkWrap: false,
          children: <Widget>[
            _showLogo(),
            _showEmailInput(),
            _showPasswordInput(),
            _showPrimaryButton(),
            _showSecondaryButton(),
            _showErrorMessage()
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
          padding: EdgeInsets.fromLTRB(0, 70, 0, 0),
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
          boxShadow: [BoxShadow(color: Colors.white, offset: Offset(2, 0), blurRadius: 5)]),
      margin: const EdgeInsets.fromLTRB(0, 65, 0, 0),
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
      child: TextFormField(
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: InputDecoration(labelText: 'Email'),
        validator: (String value) =>
            value.isEmpty ? 'Email can\'t be empty' : null,
        onSaved: (value) {
          FocusScope.of(context).requestFocus(secondNode);
          _email = value;
        },
      ),
    );
  }

  Widget _showPasswordInput() {
    bool _showPassword = false;
    return Container(decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.white, offset: Offset(2, 0), blurRadius: 5)]),
      margin: const EdgeInsets.fromLTRB(0, 10, 0, 0),
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
      child: TextFormField(
        maxLines: 1,
        obscureText: true,
        focusNode: secondNode,
        decoration: InputDecoration(
          labelText: 'Password',
        ),
        validator: (value) => value.isEmpty ? 'Password can\'t be empty' : null,
        onSaved: (value) => _password = value,
      ),
    );
  }

  Widget _showPrimaryButton() {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 30, 0, 0),
      child: RaisedButton(
        elevation: 5,
        color: Colors.white,
        child: _formMode == FormMode.LOGIN
            ? Text(
                'Login',
                style: TextStyle(fontSize: 20),
              )
            : Text(
                'Create Account',
                style: TextStyle(fontSize: 20),
              ),
        onPressed: () {
//          _validateAndSubmit;
        },
      ),
    );
  }

  Widget _showSecondaryButton() {
    return FlatButton(
      child: _formMode == FormMode.LOGIN
          ? Text('Create an account')
          : Text('Have an account? Sign in'),
      onPressed: () {
        if (_formMode == FormMode.LOGIN) {
          _changeFormToSignUp();
        } else {
          _changeFormToLogin();
        }
      },
    );
  }

  Widget _changeFormToSignUp() {
    _formKey.currentState.reset();
    _errorMessage = '';
    setState(() {
      _formMode = FormMode.SIGNUP;
    });
  }

  Widget _changeFormToLogin() {
    _formKey.currentState.reset();
    _errorMessage = '';
    setState(() {
      _formMode = FormMode.LOGIN;
    });
  }

  Widget _showErrorMessage() {
    if (_errorMessage.length > 0 && _errorMessage != null) {
      return AlertDialog(
        title: Text('Oops'),
        content: Text('Something went wrong'),
        actions: <Widget>[
          FlatButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          )
        ],
      );
    } else {
      return Container();
    }
  }
}

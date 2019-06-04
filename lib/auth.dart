import 'package:flutter/material.dart';
import 'package:project_martian/services/auth_service.dart';

class Auth extends StatefulWidget {
  final BaseAuth auth;
  final VoidCallback onSignedIn;

  Auth({this.auth, this.onSignedIn});

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
      body: Stack(children: <Widget>[_showBody(), _showCircularProgress()],),
    );
  }

  @override
  void initState() {
    _errorMessage = '';
    _isLoading = false;
    super.initState();
  }

  Widget _showCircularProgress() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator(),);
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
          boxShadow: [
            BoxShadow(color: Colors.white, offset: Offset(2, 0), blurRadius: 5)
          ]),
      margin: const EdgeInsets.fromLTRB(0, 65, 0, 0),
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 5),
      child: TextFormField(
        cursorColor: Colors.deepOrangeAccent,
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        autofocus: false,
        decoration: InputDecoration(
            labelText: 'Email'),
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
          style: TextStyle(fontSize: 20,
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
          ? Text('Create an account', style: TextStyle(color: Colors.white),)
          : Text(
          'Have an account? Sign in', style: TextStyle(color: Colors.white)),
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
          widget.auth.sendEmailVerificiation();
          _changeFormToLogin();
          Scaffold.of(context).showSnackBar(SnackBar(
            content: Text('Verification email sent'),
            duration: Duration(seconds: 3),));
          print('Signed up user: $userId');
        }
        setState(() {
          _isLoading = false;
        });
        if (userId != null && userId.length > 0 &&
            _formMode == FormMode.LOGIN) {
          widget.onSignedIn();
        }
      } catch (e) {
        print(e);
      }
    }
  }
}

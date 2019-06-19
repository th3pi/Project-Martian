import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:swipedetector/swipedetector.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

import 'package:project_martian/widgets/bank_page/bank_card.dart';
import 'models/finance_data.dart';
import 'package:project_martian/widgets/bank_page/bank_transactions.dart';
import 'package:project_martian/widgets/bank_page/transaction_details.dart';
import 'widgets/bank_page/recent_transactions.dart';
import 'widgets/flushbar.dart';
import 'widgets/testAlert.dart';

class Bank extends StatefulWidget {
  final String email;

  Bank({this.email});

  @override
  State<StatefulWidget> createState() {
    return _BankState();
  }
}

enum DataStatus { DETERMINED, NOT_DETERMINED }

class _BankState extends State<Bank> {
  var _controller = MoneyMaskedTextController(
      leftSymbol: '\$', decimalSeparator: '.', thousandSeparator: ',');
  var _imageFile, _image, _imageFile2;
  String _receiverEmail,
      _appBarTitle = 'Financial Details';
  RegExp _regExp;
  Finance _finance;
  double _balance, _amount, _mlAmount;
  DataStatus _dataStatus = DataStatus.NOT_DETERMINED;
  List<Map<String, dynamic>> _sortedTransactions = [];
  bool _userExists = false;

  @override
  void initState() {
    super.initState();
    _finance = Finance(email: widget.email);
    _finance.getData().then((value) {
      setState(() {
        _dataStatus =
            value == null ? DataStatus.NOT_DETERMINED : DataStatus.DETERMINED;
        if (value != null) {
          _finance.getBalance(null).then((value) {
            _balance = value;
          });
        }
        _finance.checkForBalanceChanges().then((data) {
          data.snapshots().listen((value) {
            value.documentChanges.forEach((change) {
//              finance = Finance(email: widget.email);
            });
          });
        });
      });
    });
    Firestore.instance
        .collection('users')
        .document(widget.email)
        .collection('transactions')
        .orderBy('dateTimeOfTransaction', descending: true)
        .snapshots()
        .listen((onData) {
      _dataStatus =
          onData == null ? DataStatus.NOT_DETERMINED : DataStatus.DETERMINED;
      if (onData != null) {
        onData.documents.forEach((f) {
          if (this.mounted) {
            setState(() {
              _sortedTransactions.add(f.data);
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            _appBarTitle,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[_showRefreshButton()],
        ),
        body: Stack(
          children: <Widget>[
            _showBody(),
            Transactions(
              email: widget.email,
              appBarTitle: _appBarTitle,
            ),
          ],
        ));
  }

  Widget _recentTransactions() {
    return RecentTransactions(
      email: widget.email,
    );
  }

  Widget _showRefreshButton() {
    return FlatButton(
        child: Text(
          'Refresh',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext) => Bank(
                        email: widget.email,
                      )));
        });
  }

  Widget _showBody() {
    return Column(
      children: <Widget>[
        SwipeDetector(
          onSwipeDown: () {
            Navigator.pop(context);
          },
          child: BankCard(
            email: widget.email,
          ),
        ),
        _dataStatus == DataStatus.NOT_DETERMINED
            ? SpinKitDualRing(color: Colors.deepOrangeAccent)
            : _showSendDepositMoney(),
        _recentTransactions(),
      ],
    );
  }

  void _restartPageNotificationPicDeposit(double amount) {
    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      isDismissible: true,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticOut,
      icon: Icon(
        Icons.check_circle_outline,
        color: Colors.white,
      ),
      shouldIconPulse: true,
      backgroundColor: Colors.green,
      flushbarStyle: FlushbarStyle.FLOATING,
      borderRadius: 3,
      aroundPadding: EdgeInsets.all(15),
      boxShadows: [
        BoxShadow(
          color: Colors.black26,
          offset: Offset(0.0, 2.0),
          blurRadius: 3.0,
        )
      ],
      mainButton: FlatButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext) => Bank(
                          email: widget.email,
                        )));
          },
          child: Text(
            'Refresh',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          )),
      titleText: Text(
        '\$$amount was deposited to your account',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      messageText: Text(
        'Click refresh to see new transactions and their details',
        style: TextStyle(color: Colors.white),
      ),
      duration: Duration(seconds: 6),
    ).show(context);
  }

  void _restartPageNotification() {
    Flushbar(
      flushbarPosition: FlushbarPosition.TOP,
      isDismissible: true,
      reverseAnimationCurve: Curves.decelerate,
      forwardAnimationCurve: Curves.elasticOut,
      icon: Icon(
        Icons.check_circle_outline,
        color: Colors.white,
      ),
      shouldIconPulse: true,
      backgroundColor: Colors.green,
      flushbarStyle: FlushbarStyle.FLOATING,
      borderRadius: 3,
      aroundPadding: EdgeInsets.all(15),
      boxShadows: [
        BoxShadow(
          color: Colors.black26,
          offset: Offset(0.0, 2.0),
          blurRadius: 3.0,
        )
      ],
      mainButton: FlatButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (BuildContext) => Bank(
                          email: widget.email,
                        )));
          },
          child: Text(
            'Refresh',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          )),
      titleText: Text(
        'Transaction completed',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      messageText: Text(
        'Click refresh to see new transactions and their details',
        style: TextStyle(color: Colors.white),
      ),
      duration: Duration(seconds: 6),
    ).show(context);
  }

  Future<void> _takePicture() async {
    _imageFile = await ImagePicker.pickImage(source: ImageSource.camera);
    _image = FirebaseVisionImage.fromFile(_imageFile);
    TextRecognizer recognizeText = FirebaseVision.instance.textRecognizer();
    VisionText readText = await recognizeText.processImage(_image);
    _regExp = RegExp(r"(\d)");
    for (TextBlock block in readText.blocks) {
      for (TextLine line in block.lines) {
        for (TextElement word in line.elements) {
          if (_regExp.hasMatch(word.text)) {
            setState(() {
              _mlAmount = double.parse(word.text);
              _finance.depositMoney(_mlAmount);
              _restartPageNotificationPicDeposit(_mlAmount);
            });
          } else {
            print('No match');
          }
        }
      }
    }
  }

  Widget _showSendDepositMoney() {
    return Container(
      child: Card(
        elevation: 20,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 50,
                width: 175,
                child: RaisedButton(
                  color: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[Icon(Icons.call_received, color: Colors.white,),SizedBox(width: 15,),
                      Text(
                        'Deposit',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  onPressed: () {
                    _depositAlert();
                  },
                ),
              ),
              Container(
                width: 1,
                height: 20,
                color: Colors.white70,
                margin: EdgeInsets.only(left: 10, right: 10),
              ),
              Container(
                height: 50,
                width: 175,
                child: RaisedButton(
                  color: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[Icon(Icons.send, color: Colors.white,),SizedBox(width: 15,),
                      Text(
                        'Send',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  onPressed: () {
                    _sendMoneyAlert();
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void _sendMoneyAlert() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            content: Container(
              height: 220,
              child: Column(
                children: <Widget>[
                  Card(
                      elevation: 0,
                      borderOnForeground: false,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Container(
                          decoration:
                              BoxDecoration(color: Colors.deepOrangeAccent),
                          padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                          child: Center(
                            child: Text(
                              'Send Money',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ))),
                  Container(
                      width: 250,
                      child: Card(
                        child: Container(
                          padding: EdgeInsets.only(left: 15),
                          child: TextField(
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (value) {
                              _receiverEmail = value;
                              _finance
                                  .checkIfUserExists(_receiverEmail)
                                  .then((value) {
                                setState(() {
                                  if (value != null) {
                                    _userExists = value;
                                    print(value);
                                  }
                                });
                              });
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              labelText: 'Receiver\'s Email',
                            ),
                          ),
                        ),
                        elevation: 20,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      )),
                  Container(
                      width: 250,
                      child: Card(
                        child: Container(
                          padding: EdgeInsets.only(left: 15),
                          child: TextField(
                            keyboardType: TextInputType.number,
                            controller: _controller,
                            onChanged: (value) {
                              _amount = _controller.numberValue;
                            },
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              labelText: 'Amount',
                            ),
                          ),
                        ),
                        elevation: 20,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      )),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel',
                      style: TextStyle(color: Colors.deepOrangeAccent))),
              RaisedButton(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                elevation: 0,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Text(
                  'Confirm & Send',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  if (_dataStatus == DataStatus.DETERMINED) {
                    if (_balance >= _amount) {
                      if (_userExists) {
                        _restartPageNotification();
                        _finance.sendMoney(_amount, _receiverEmail).then((value) {
                          setState(() {
                            _finance.getBalance(null).then((value) {
                              _balance = value;
                            });
                          });
                        });
                      } else {
                        CustomFlushbar(context: context)
                            .userDoesntExistNotification();
                      }
                    } else if (_balance < _amount) {
                      CustomFlushbar(context: context).lowBalanceNotification();
                    }
                  }
                },
              )
            ],
          );
        });
  }

  void _depositAlert() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            content: Container(
              height: 220,
              child: Column(
                children: <Widget>[
                  Card(
                      elevation: 0,
                      borderOnForeground: false,
                      clipBehavior: Clip.antiAlias,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: Container(
                          decoration:
                              BoxDecoration(color: Colors.deepOrangeAccent),
                          padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                          child: Center(
                            child: Text(
                              'Pick an Option',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ))),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                      width: 250,
                      child: RaisedButton(
                        color: Colors.white,
                        padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[Icon(Icons.camera_alt, color: Colors.deepOrange,), SizedBox(width: 10,),
                            Text(
                              'Submit Check',
                              style: TextStyle(color: Colors.deepOrange, fontSize: 20),
                            ),
                          ],
                        ),
                        elevation: 20,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        onPressed: () {
                          _takePicture();
                          Navigator.pop(context);
                        },
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                      width: 250,
                      child: RaisedButton(
                        child: Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Direct Deposit',
                              style: TextStyle(color: Colors.deepOrange),
                            ),
                          ],
                        ),
                        elevation: 20,
                        color: Colors.white,
                        padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        onPressed: () {
                          Navigator.pop(context);
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15)),
                                  content: Container(
                                    height: 150,
                                    child: Column(
                                      children: <Widget>[
                                        Card(
                                            elevation: 0,
                                            borderOnForeground: false,
                                            clipBehavior: Clip.antiAlias,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: Container(
                                                decoration: BoxDecoration(
                                                    color: Colors
                                                        .deepOrangeAccent),
                                                padding: EdgeInsets.fromLTRB(
                                                    0, 20, 0, 20),
                                                child: Center(
                                                  child: Text(
                                                    'Deposit Money',
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Colors.white),
                                                  ),
                                                ))),
                                        Container(
                                            width: 250,
                                            child: Card(
                                              child: Container(
                                                padding:
                                                    EdgeInsets.only(left: 15),
                                                child: TextField(
                                                  keyboardType:
                                                      TextInputType.number,
                                                  controller: _controller,
                                                  onChanged: (value) {
                                                    _amount =
                                                        _controller.numberValue;
                                                  },
                                                  decoration: InputDecoration(
                                                    border: InputBorder.none,
                                                    labelText: 'Amount',
                                                  ),
                                                ),
                                              ),
                                              elevation: 20,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          15)),
                                            )),
                                      ],
                                    ),
                                  ),
                                  actions: <Widget>[
                                    FlatButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text('Cancel',
                                            style: TextStyle(
                                                color:
                                                    Colors.deepOrangeAccent))),
                                    RaisedButton(
                                      padding:
                                          EdgeInsets.fromLTRB(20, 0, 20, 0),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(15)),
                                      child: Text(
                                        'Confirm & Deposit',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white),
                                      ),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        _restartPageNotification();
                                        _finance.depositMoney(_amount);
                                      },
                                    )
                                  ],
                                );
                              });
                        },
                      )),
                ],
              ),
            ),
          );
        });
  }
}

import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:swipedetector/swipedetector.dart';
import 'package:flutter_masked_text/flutter_masked_text.dart';

import 'package:project_martian/widgets/bank_page/bank_card.dart';
import 'models/finance_data.dart';
import 'package:project_martian/widgets/bank_page/bank_transactions.dart';
import 'package:project_martian/widgets/bank_page/transaction_details.dart';
import 'widgets/bank_page/recent_transactions.dart';

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
  var controller = MoneyMaskedTextController(leftSymbol: '\$', decimalSeparator: '.', thousandSeparator: ',');
  String receiverEmail;
  Finance finance;
  double balance, amount;
  DataStatus dataStatus = DataStatus.NOT_DETERMINED;
  List<Map<String, dynamic>> sortedTransactions = [];

  @override
  void initState() {
    super.initState();
    finance = Finance(email: widget.email);
    finance.getData().then((value) {
      setState(() {
        dataStatus =
            value == null ? DataStatus.NOT_DETERMINED : DataStatus.DETERMINED;
        if (value != null) {
          finance.getBalance(null).then((value) {
            balance = value;
          });
        }
        finance.checkForBalanceChanges().then((data) {
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
      dataStatus =
          onData == null ? DataStatus.NOT_DETERMINED : DataStatus.DETERMINED;
      if (onData != null) {
        onData.documents.forEach((f) {
          if (this.mounted) {
            setState(() {
              sortedTransactions.add(f.data);
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
            'Financial Details',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Stack(
          children: <Widget>[
            _showBody(),
            Transactions(
              email: widget.email,
            ),
          ],
        ));
  }

  Widget _recentTransactions() {
    return RecentTransactions(
      email: widget.email,
    );
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
        _showSendDepositMoney(),
        _recentTransactions(),
      ],
    );
  }

  void restartPageNotification() {
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

  Widget _showSendDepositMoney() {
    return Container(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                    children: <Widget>[
                      Text(
                        'Deposit',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  onPressed: () {
                    restartPageNotification();
                    finance.depositMoney(200).then((value) {
                      setState(() {
                        finance.getBalance(null).then((value) {
                          balance = value;
                        });
                      });
                    });
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
                    children: <Widget>[
                      Text(
                        'Send',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            content: Container(
                              height: 220,
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
                                              color: Colors.deepOrangeAccent),
                                          padding:
                                              EdgeInsets.fromLTRB(0, 20, 0, 20),
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
                                          child: TextField(keyboardType: TextInputType.emailAddress,
                                            onChanged: (value) {
                                              receiverEmail = value;
                                            },
                                            decoration: InputDecoration(
                                              border: InputBorder.none,
                                              labelText: 'Receiver\'s Email',
                                            ),
                                          ),
                                        ),
                                        elevation: 20,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                      )),
                                  Container(
                                      width: 250,
                                      child: Card(
                                        child: Container(
                                          padding: EdgeInsets.only(left: 15),
                                          child: TextField(keyboardType: TextInputType.number, controller: controller,
                                            onChanged: (value) {
                                              amount = controller.numberValue;
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
                                                BorderRadius.circular(15)),
                                      )),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              FlatButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Cancel',
                                      style: TextStyle(
                                          color: Colors.deepOrangeAccent))),
                              RaisedButton(padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                child: Text(
                                  'Confirm & Send',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                  restartPageNotification();
                                  finance
                                      .sendMoney(amount, receiverEmail)
                                      .then((value) {
                                    setState(() {
                                      finance.getBalance(null).then((value) {
                                        balance = value;
                                      });
                                    });
                                  });
                                },
                              )
                            ],
                          );
                        });
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:swipedetector/swipedetector.dart';

import 'package:project_martian/widgets/bank_page/bank_card.dart';
import 'models/finance_data.dart';
import 'package:project_martian/widgets/bank_page/bank_transactions.dart';
import 'package:project_martian/widgets/bank_page/TransactionDetails.dart';
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
  Finance finance;
  double balance;
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
          balance = value['balance'];
        }
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
          setState(() {
            sortedTransactions.add(f.data);
          });
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
                    finance.depositMoney(200, balance).then((value) {
                      setState(() {
                        balance += 200;
                        finance.setBalance(balance);
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
                    restartPageNotification();
                    finance.sendMoney(200, balance).then((value) {
                      setState(() {
                        balance -= 200;
                        finance.setBalance(balance);
                      });
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

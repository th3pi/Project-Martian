import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:swipedetector/swipedetector.dart';

import 'widgets/bank_card.dart';
import 'models/finance_data.dart';
import 'widgets/bank_transactions.dart';
import 'widgets/TransactionDetails.dart';

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
        _showRecentNotifications(),
      ],
    );
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

  Widget _showRecentNotifications() {
    return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          padding: EdgeInsets.only(left: 10),
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(5, 15, 10, 10),
                child: Row(
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return TransactionDetails(
                                i: 0,
                                sortedTransactions: sortedTransactions,
                              );
                            });
                      },
                      child: sortedTransactions[0]['transactionType'] == 'send'
                          ? Text(
                              'You have sent \$200 to some@gmail.com',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )
                          : Text(
                              '\$200 was added to your account',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                    Tooltip(
                      message: sortedTransactions[0]['timeOfTransaction'],
                      child: Text(sortedTransactions[0]['dateOfTransaction'],
                          style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
              ),
              Divider(),
              Container(
                padding: EdgeInsets.fromLTRB(5, 15, 10, 10),
                child: Row(
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return TransactionDetails(
                                i: 1,
                                sortedTransactions: sortedTransactions,
                              );
                            });
                      },
                      child: sortedTransactions[1]['transactionType'] == 'send'
                          ? Text(
                              'You have sent \$200 to some@gmail.com',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )
                          : Text(
                              '\$200 was added to your account',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                    Tooltip(
                      message: sortedTransactions[1]['timeOfTransaction'],
                      child: Text(sortedTransactions[1]['dateOfTransaction'],
                          style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
              ),
              Divider(),
              Container(
                padding: EdgeInsets.fromLTRB(5, 15, 10, 10),
                child: Row(
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return TransactionDetails(
                                i: 2,
                                sortedTransactions: sortedTransactions,
                              );
                            });
                      },
                      child: sortedTransactions[2]['transactionType'] == 'send'
                          ? Text(
                              'You have sent \$200 to some@gmail.com',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )
                          : Text(
                              '\$200 was added to your account',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                    ),
                    Tooltip(
                      message: sortedTransactions[2]['timeOfTransaction'],
                      child: Text(sortedTransactions[2]['dateOfTransaction'],
                          style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
              ),
              Divider(),
              Container(
                padding: EdgeInsets.fromLTRB(5, 15, 10, 10),
                child: Row(
                  children: <Widget>[
                    InkWell(
                      onTap: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return TransactionDetails(
                                i: 3,
                                sortedTransactions: sortedTransactions,
                              );
                            });
                      },
                      child: InkWell(
                        onTap: () {
                          showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return TransactionDetails(
                                  i: 3,
                                  sortedTransactions: sortedTransactions,
                                );
                              });
                        },
                        child: sortedTransactions[3]['transactionType'] ==
                                'send'
                            ? Text(
                                'You have sent \$200 to some@gmail.com',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            : Text(
                                '\$200 was added to your account',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                    Tooltip(
                      message: sortedTransactions[3]['timeOfTransaction'],
                      child: Text(sortedTransactions[3]['dateOfTransaction'],
                          style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ),
                  ],
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                ),
              ),
            ],
          ),
        ));
  }
}

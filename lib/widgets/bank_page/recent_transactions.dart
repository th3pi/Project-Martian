import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'TransactionDetails.dart';

class RecentTransactions extends StatefulWidget{
  final String email;

  RecentTransactions({this.email});

  @override
  State<StatefulWidget> createState() {
    return _RecentTransactionsState();
  }
}

enum DataStatus { DETERMINED, NOT_DETERMINED }

class _RecentTransactionsState extends State<RecentTransactions>{
  DataStatus dataStatus = DataStatus.NOT_DETERMINED;
  List<Map<String, dynamic>> sortedTransactions = [];
  @override
  Widget build(BuildContext context) {
    return _showRecentNotifications();
  }

  @override
  void initState(){
    super.initState();
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
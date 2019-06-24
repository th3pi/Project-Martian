import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'transaction_details.dart';

class RecentTransactions extends StatefulWidget {
  final String email;

  RecentTransactions({this.email});

  @override
  State<StatefulWidget> createState() {
    return _RecentTransactionsState();
  }
}

enum DataStatus { DETERMINED, NOT_DETERMINED }

class _RecentTransactionsState extends State<RecentTransactions> {
  DataStatus dataStatus = DataStatus.NOT_DETERMINED;
  List<Map<String, dynamic>> sortedTransactions = [];

  @override
  Widget build(BuildContext context) {
    return _showRecentNotifications();
  }

  @override
  void initState() {
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
          if (this.mounted) {
            setState(() {
              sortedTransactions.add(f.data);
            });
          }
        });
      }
    });
  }

  Widget _showRecentNotifications() {
    return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          padding: EdgeInsets.only(left: 10),
          child: sortedTransactions.length > 4
              ? Column(
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
                            child: sortedTransactions[0]['transactionType'] ==
                                    'Sent'
                                ? Text(
                                    'Sent \$${sortedTransactions[0]['amount']} to ${sortedTransactions[0]['receiver']}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )
                                : (sortedTransactions[0]['transactionType'] ==
                                        'Received'
                                    ? Text(
                                        'Received \$${sortedTransactions[0]['amount']} from ${sortedTransactions[0]['sender']}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : Text('\$${sortedTransactions[0]['amount']} was Deposited to your account',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold))),
                          ),
                          Tooltip(
                            message: sortedTransactions[0]['timeOfTransaction'],
                            child: Text(
                                sortedTransactions[0]['dateOfTransaction'],
                                style: TextStyle(
                                    fontSize: 10, color: Colors.grey)),
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
                            child: sortedTransactions[1]['transactionType'] ==
                                    'Sent'
                                ? Text(
                                    'Sent \$${sortedTransactions[1]['amount']} to ${sortedTransactions[1]['receiver']}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )
                                : (sortedTransactions[3]['transactionType'] ==
                                        'Received'
                                    ? Text(
                                        'Received \$${sortedTransactions[1]['amount']} from ${sortedTransactions[1]['sender']}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )
                                    : Text(
                                        '\$${sortedTransactions[1]['amount']} was Deposited to your account',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )),
                          ),
                          Tooltip(
                            message: sortedTransactions[1]['timeOfTransaction'],
                            child: Text(
                                sortedTransactions[1]['dateOfTransaction'],
                                style: TextStyle(
                                    fontSize: 10, color: Colors.grey)),
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
                            child: sortedTransactions[2]['transactionType'] ==
                                    'Sent'
                                ? Text(
                                    'Sent \$${sortedTransactions[3]['amount']} to ${sortedTransactions[2]['receiver']}',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )
                                : (sortedTransactions[2]['transactionType'] ==
                                        'Received'
                                    ? Text(
                                        'Received \$${sortedTransactions[2]['amount']} from ${sortedTransactions[2]['sender']}',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )
                                    : Text(
                                        '\$${sortedTransactions[2]['amount']} was Deposited to your account',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      )),
                          ),
                          Tooltip(
                            message: sortedTransactions[2]['timeOfTransaction'],
                            child: Text(
                                sortedTransactions[2]['dateOfTransaction'],
                                style: TextStyle(
                                    fontSize: 10, color: Colors.grey)),
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
                                      'Sent'
                                  ? Text(
                                      'Sent \$${sortedTransactions[3]['amount']} to ${sortedTransactions[3]['receiver']}',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )
                                  : (sortedTransactions[3]['transactionType'] ==
                                          'Received'
                                      ? Text(
                                          'Received \$${sortedTransactions[3]['amount']} from ${sortedTransactions[3]['sender']}',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )
                                      : Text(
                                          '\$${sortedTransactions[3]['amount']} was Deposited to your account',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        )),
                            ),
                          ),
                          Tooltip(
                            message: sortedTransactions[3]['timeOfTransaction'],
                            child: Text(
                                sortedTransactions[3]['dateOfTransaction'],
                                style: TextStyle(
                                    fontSize: 10, color: Colors.grey)),
                          ),
                        ],
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      ),
                    ),
                  ],
                )
              : Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(10, 25, 10, 25),
                  child: Text(
                    'Nothing to show here... yet!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black87),
                  ),
                ),
        ));
  }
}

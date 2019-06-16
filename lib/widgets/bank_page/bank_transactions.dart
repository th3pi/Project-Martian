import 'package:flutter/material.dart';
import 'package:project_martian/models/finance_data.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:project_martian/widgets/bank_page/transaction_details.dart';

class Transactions extends StatefulWidget {
  final String email, appBarTitle;

  Transactions({this.email, this.appBarTitle});

  @override
  State<StatefulWidget> createState() {
    return _TransactionState();
  }
}

enum DataStatus { DETERMINED, NOT_DETERMINED }

class _TransactionState extends State<Transactions> {
  int perPage = 10;
  int present = 0;
  DataStatus dataStatus = DataStatus.NOT_DETERMINED;
  Finance finance;
  List<Map<String, dynamic>> sortedTransactions = [];
  List<Map<String, dynamic>> limitedTransactions = [];
  int numOfTransactions;

  @override
  Widget build(BuildContext context) {
    return _showSlideUpPanel();
  }

  @override
  void initState() {
    super.initState();
    print(widget.email);
    Firestore.instance
        .collection('users')
        .document(widget.email)
        .collection('transactions')
        .orderBy('dateTimeOfTransaction', descending: true)
        .snapshots()
        .listen((onData) {
      dataStatus =
          onData == null ? DataStatus.NOT_DETERMINED : DataStatus.DETERMINED;
      if (this.mounted) {
        setState(() {
          numOfTransactions = onData.documents.length;
        });
      }
      print(numOfTransactions);
      if (onData != null) {
        onData.documents.forEach((f) {
          if (this.mounted) {
            setState(() {
              sortedTransactions.add(f.data);
            });
          }
        });
        setState(() {
          limitedTransactions
              .addAll(sortedTransactions.getRange(present, perPage));
          present += perPage;
        });
      }
    });
  }

  Widget _showSlideUpPanel() {
    return SlidingUpPanel(
        backdropEnabled: true,
        backdropTapClosesPanel: true,
        color: Colors.deepOrangeAccent,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        collapsed: _collapsed(),
        panel: _panel());
  }

  Widget _collapsed() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                color: Colors.deepOrangeAccent,
                borderRadius: BorderRadius.circular(35)),
            width: 30,
            height: 5,
          ),
          Container(
              child: Center(
            child: Text('More Transactions',
                style: TextStyle(
                  color: Colors.deepOrangeAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                )),
          )),
        ],
      ),
    );
  }

  Widget _panel() {
    return Stack(alignment: Alignment.topCenter, children: <Widget>[
      Container(
          padding: EdgeInsets.only(top: 8),
          child: Text(
            'Swipe down to Close',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          )),
      Container(
          margin: EdgeInsets.only(top: 35),
          color: Colors.white,
          child: ListView.builder(
            itemCount: present <= sortedTransactions.length
                ? limitedTransactions.length + 1
                : limitedTransactions.length,
            itemBuilder: (BuildContext context, int i) {
              return i != limitedTransactions.length
                  ? Container(
                      child: Container(
                          child: InkWell(
                        onTap: () {
                          _showTransactionDetails(i);
                        },
                        child: Card(
                            elevation: 50,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            child: Container(
                              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      Text("${getTransactionDay(i)}",
                                          style: TextStyle(
                                            fontSize: 10,
                                          )),
                                      Text("${getTransactionBalance(i)}",
                                          style: TextStyle(
                                            fontSize: 10,
                                          )),
                                    ],
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      Text(
                                          sortedTransactions[i]
                                                      ['transactionType'] ==
                                                  'Sent'
                                              ? 'Sent to: ${sortedTransactions[i]['receiver']}'
                                              : (sortedTransactions[i]
                                                          ['transactionType'] ==
                                                      'Received'
                                                  ? 'From: ${sortedTransactions[i]['sender']}'
                                                  : 'Deposit'),
                                          style: TextStyle(
                                            fontSize: 15,
                                          )),
                                      sortedTransactions[i]
                                                  ['transactionType'] ==
                                              'Sent'
                                          ? Text(
                                              '-\$${sortedTransactions[i]['amount']}',
                                              style: TextStyle(
                                                  color: Colors.red,
                                                  fontWeight: FontWeight.bold),
                                            )
                                          : Text(
                                              '+\$${sortedTransactions[i]['amount']}',
                                              style: TextStyle(
                                                  color: Colors.green,
                                                  fontWeight: FontWeight.bold),
                                            )
                                    ],
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                  ),
                                ],
                              ),
                            )),
                      )),
                    )
                  : Container(
                      color: Colors.deepOrangeAccent,
                      child: FlatButton(
                        child: Text('Load More', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                        onPressed: () {
                          setState(() {
                            if ((present + perPage) >
                                sortedTransactions.length) {
                              limitedTransactions.addAll(
                                  sortedTransactions.getRange(
                                      present, sortedTransactions.length));
                            } else {
                              limitedTransactions.addAll(sortedTransactions
                                  .getRange(present, present + perPage));
                            }
                          });
                          present += perPage;
                        },
                      ),
                    );
            },
          )),
    ]);
  }

  void _showTransactionDetails(int i) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return TransactionDetails(
            i: i,
            sortedTransactions: sortedTransactions,
          );
        });
  }

  String getTransactionType(int i) {
    return sortedTransactions[i]['transactionType'];
  }

  String getTransactionDay(int i) {
    return sortedTransactions[i]['dateOfTransaction'];
  }

  String getTransactionAmount(int i) {
    return sortedTransactions[i]['dayOfTransaction'];
  }

  String getTransactionBalance(int i) {
    double bal = sortedTransactions[i]['balance'];
    return bal.toStringAsFixed(2);
  }
}

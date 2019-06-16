import 'package:flutter/material.dart';

class TransactionDetails extends StatelessWidget {
  final int i;
  final List<Map<String, dynamic>> sortedTransactions;

  TransactionDetails({this.i, this.sortedTransactions});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 10),
              child: Card(
                  elevation: 0,
                  borderOnForeground: false,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Container(
                      decoration: BoxDecoration(color: Colors.deepOrangeAccent),
                      padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                      child: Center(
                          child: Column(
                        children: <Widget>[
                          Text(
                            'Transaction ID',
                            style: TextStyle(color: Colors.white),
                          ),
                          Text(
                            sortedTransactions[i]['transactionId'],
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ],
                      )))),
            ),
            Container(
              child: Card(
                clipBehavior: Clip.antiAlias,
                elevation: 1,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Column(
                        children: <Widget>[
                          Text(
                            'Transaction type',
                            style: TextStyle(fontSize: 12),
                          ),
                          Text(
                            '${sortedTransactions[i]['transactionType']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                    Divider(),
                    Container(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Column(
                        children: <Widget>[
                          Text(
                            'Amount',
                            style: TextStyle(fontSize: 12),
                          ),
                          Text(
                            '\$200',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                    sortedTransactions[i]['transactionType'] == 'Sent'
                        ? Container(
                            padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                            child: Column(
                              children: <Widget>[
                                Text(
                                  'Sent to',
                                  style: TextStyle(fontSize: 12),
                                ),
                                Text(
                                  sortedTransactions[i]['receiver'],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                )
                              ],
                            ),
                          )
                        : (sortedTransactions[i]['transactionType'] ==
                                'Received'
                            ? Container(
                                padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                child: Column(
                                  children: <Widget>[
                                    Text(
                                      'From',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    Text(
                                      sortedTransactions[i]['sender'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                              )
                            : SizedBox()),
                    Divider(),
                    Container(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Column(
                        children: <Widget>[
                          Text(
                            'Date of Transaction',
                            style: TextStyle(fontSize: 12),
                          ),
                          Text(
                            '${sortedTransactions[i]['dateOfTransaction']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                    Divider(),
                    Container(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Column(
                        children: <Widget>[
                          Text(
                            'Time of Transaction',
                            style: TextStyle(fontSize: 12),
                          ),
                          Text(
                            '${sortedTransactions[i]['timeOfTransaction']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                    Divider(),
                    Container(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      child: Column(
                        children: <Widget>[
                          Text(
                            'Balance at the Time',
                            style: TextStyle(fontSize: 12),
                          ),
                          Text(
                            '${sortedTransactions[i]['balance']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}

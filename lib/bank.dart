import 'package:flutter/material.dart';

import 'widgets/bank_card.dart';
import 'models/finance_data.dart';
import 'widgets/bank_transactions.dart';

class Bank extends StatefulWidget {
  final String userId;

  Bank({this.userId});

  @override
  State<StatefulWidget> createState() {
    return _BankState();
  }
}

class _BankState extends State<Bank> {
  Finance finance;

  @override
  void initState() {
    super.initState();
    finance = Finance(userId: widget.userId);
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
            BankCard(
              userId: widget.userId,
            ),
            Transactions(),
          ],
        ));
  }
}

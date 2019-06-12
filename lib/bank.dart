import 'package:flutter/material.dart';

import 'widgets/bank_card.dart';

class Bank extends StatefulWidget {
  final String balance;

  Bank({this.balance});

  @override
  State<StatefulWidget> createState() {
    return _BankState();
  }
}

class _BankState extends State<Bank> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bank of Mars'),
      ),
      body: BankCard(
        balance: widget.balance,
      ),
    );
  }
}

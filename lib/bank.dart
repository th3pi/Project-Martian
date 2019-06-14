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

enum DataStatus { DETERMINED, NOT_DETERMINED }

class _BankState extends State<Bank> {
  Finance finance;
  double balance;
  DataStatus dataStatus = DataStatus.NOT_DETERMINED;
  List<Map<String, dynamic>> sortedTransactions = [];

  @override
  void initState() {
    super.initState();
    finance = Finance(userId: widget.userId);
    finance.getData().then((value) {
      setState(() {
        dataStatus = value == null ? DataStatus.NOT_DETERMINED : DataStatus.DETERMINED;
        if(value != null) {
          balance = value['balance'];
        }
      });
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
            Transactions(userId: widget.userId,),
          ],
        ));
  }

  Widget _showBody() {
    return Column(
      children: <Widget>[
        BankCard(
          userId: widget.userId,
        ),
        _showSendDepositMoney()
      ],
    );
  }

  Widget _showSendDepositMoney() {
    return Card(
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
                    borderRadius: BorderRadius.circular(15)),
                child: Text(
                  'Deposit',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
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
                    borderRadius: BorderRadius.circular(15)),
                child: Text(
                  'Send',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                onPressed: () { finance.sendMoney(200, balance).then((value){
                  setState(() {
                    balance -= 200;
                    finance.setBalance(balance);
                  });
                }
                );},
              ),
            )
          ],
        ),
      ),
    );
  }
}

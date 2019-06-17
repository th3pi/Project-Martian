import 'package:flutter/material.dart';
import 'package:flushbar/flushbar.dart';
import 'package:project_martian/bank.dart';

class DirectDepositAlert extends StatefulWidget{
  final controller;
  final finance;
  final String email;
  final BuildContext context;
  DirectDepositAlert({this.controller, this.finance,this.email, this.context});

  @override
  State<StatefulWidget> createState() {
    return _DirectDepositAlertState();
  }
}

class _DirectDepositAlertState extends State<DirectDepositAlert>{
  double amount;

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
    ).show(widget.context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius:
          BorderRadius.circular(
              15)),
      content: Container(
        height: 150,
        child: Column(
          children: <Widget>[
            Card(
                elevation: 0,
                borderOnForeground:
                false,
                clipBehavior:
                Clip.antiAlias,
                shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius
                        .circular(
                        10)),
                child: Container(
                    decoration: BoxDecoration(
                        color: Colors
                            .deepOrangeAccent),
                    padding:
                    EdgeInsets
                        .fromLTRB(
                        0,
                        20,
                        0,
                        20),
                    child: Center(
                      child: Text(
                        'Deposit Money',
                        style: TextStyle(
                            fontSize:
                            20,
                            fontWeight:
                            FontWeight
                                .bold,
                            color: Colors
                                .white),
                      ),
                    ))),
            Container(
                width: 250,
                child: Card(
                  child: Container(
                    padding: EdgeInsets
                        .only(
                        left:
                        15),
                    child:
                    TextField(
                      keyboardType:
                      TextInputType
                          .number,
                      controller:
                      widget.controller,
                      onChanged:
                          (value) {
                        amount =
                            widget.controller
                                .numberValue;
                      },
                      decoration:
                      InputDecoration(
                        border:
                        InputBorder
                            .none,
                        labelText:
                        'Amount',
                      ),
                    ),
                  ),
                  elevation: 20,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius
                          .circular(
                          15)),
                )),
          ],
        ),
      ),
      actions: <Widget>[
        FlatButton(
            onPressed: () =>
                Navigator.pop(
                    context),
            child: Text('Cancel',
                style: TextStyle(
                    color: Colors
                        .deepOrangeAccent))),
        RaisedButton(
          padding:
          EdgeInsets.fromLTRB(
              20, 0, 20, 0),
          elevation: 0,
          shape:
          RoundedRectangleBorder(
              borderRadius:
              BorderRadius
                  .circular(
                  15)),
          child: Text(
            'Confirm & Deposit',
            style: TextStyle(
                fontWeight:
                FontWeight.bold,
                color:
                Colors.white),
          ),
          onPressed: () {
            Navigator.pop(context);
            restartPageNotification();
            widget.finance.depositMoney(
                amount);
          },
        )
      ],
    );
  }
}
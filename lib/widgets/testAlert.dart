import 'package:flutter/material.dart';

class TestAlert extends StatefulWidget{
  final double amount;
  TestAlert({this.amount});

  @override
  State<StatefulWidget> createState() {
    return _TestAlertState();
  }
}

enum DataStatus {NOT_DETERMINED, DETERMINED}

class _TestAlertState extends State<TestAlert>{
  DataStatus dataStatus = DataStatus.NOT_DETERMINED;
  @override
  void initState() {
    super.initState();
    setState(() {
      dataStatus = widget.amount == null ? DataStatus.NOT_DETERMINED : DataStatus.DETERMINED;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        height: 250,
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
                        'Confirm Amount',
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
                        50,
                        0,
                        50),
                    child: Center(
                      child: Row(
                        children: <Widget>[
                          Text(
                            'Amount',
                            style: TextStyle(
                                fontSize:
                                15,
                                color: Colors
                                    .white),
                          ),
                          Text(
                            '${widget.amount}',
                            style: TextStyle(
                                fontSize:
                                25,
                                fontWeight:
                                FontWeight
                                    .bold,
                                color: Colors
                                    .white),
                          ),
                        ],
                      ),
                    )))
          ],
        ),
      ),
      actions: <Widget>[
        RaisedButton(
          child: Text(
              'Confirm & Deposit'),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      ],
    );
  }
}
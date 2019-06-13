import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class Transactions extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _TransactionState();
  }
}

class _TransactionState extends State<Transactions> {
  @override
  Widget build(BuildContext context) {
    return _showSlideUpPanel();
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
            itemBuilder: (BuildContext context, int i) {
              return Container(
                padding: const EdgeInsets.all(12.0),
                child: Text("$i"),
              );
            },
          )),
    ]);
  }
}

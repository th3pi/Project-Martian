import 'package:flutter/material.dart';

class Header extends StatelessWidget{
  final String text;

  Header({this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
            alignment: Alignment.topLeft,
            padding: EdgeInsets.fromLTRB(10, 10, 0, 5),
            child: Text(
              text,
              style: TextStyle(
                  fontSize: 25,
                  color: Colors.deepOrangeAccent,
                  fontFamily: 'SamsungOne',
                  fontWeight: FontWeight.bold),
            )),
        Divider(
          color: Colors.black12,
        ),
      ],
    );
  }
}
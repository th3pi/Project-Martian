import 'package:flutter/material.dart';

import 'auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Martian',
      theme: ThemeData(primarySwatch: Colors.deepOrange, accentColor: Colors.deepOrangeAccent, fontFamily: 'SamsungOne'),
      home: Auth(),
    );
  }
}

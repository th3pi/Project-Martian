import 'package:flutter/material.dart';
import 'package:project_martian/services/auth_service.dart';

import 'root.dart';
import 'auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project Martian',
      theme: ThemeData(primarySwatch: Colors.deepOrange, accentColor: Colors.deepOrangeAccent, fontFamily: 'SamsungOne'),
      home: RootPage(auth: Auth(),),
      debugShowCheckedModeBanner: false,
    );
  }
}

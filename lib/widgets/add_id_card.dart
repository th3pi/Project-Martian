import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../forms/id_form.dart';

class AddIdCard extends StatefulWidget{
  final String email;
  final BaseAuth auth;
  final double scale;

  AddIdCard({this.email, this.auth, this.scale});

  @override
  State<StatefulWidget> createState() {
    return _AddIdCardState();
  }
}

class _AddIdCardState extends State<AddIdCard>{
  int pagerHeight = 200;
  @override
  Widget build(BuildContext context) {
    return _showAddIdCard(widget.scale);
  }

  Widget _showAddIdCard(double scale) {
    return InkWell(
      splashColor: Colors.deepOrangeAccent,
      onTap: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext) => IdForm(
                email: widget.email,
                auth: widget.auth,
              ))),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: EdgeInsets.only(bottom: 20),
          height: pagerHeight * scale,
          width: 800,
          child: Card(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 10,
            clipBehavior: Clip.antiAlias,
            child: Center(
              child: Icon(
                Icons.add_circle_outline,
                size: 50,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
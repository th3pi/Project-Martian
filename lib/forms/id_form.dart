import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:project_martian/services/auth_service.dart';

class IdForm extends StatefulWidget{
  final String userId;
  final BaseAuth auth;

  IdForm({this.userId, this.auth});

  @override
  State<StatefulWidget> createState() {
    return _IdFormState();
  }
}

class _IdFormState extends State<IdForm>{
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return null;
  }

}
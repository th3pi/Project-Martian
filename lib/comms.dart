import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'models/contacts_data.dart';
import 'services/auth_service.dart';

class Comms extends StatefulWidget {
  final String email;
  final BaseAuth auth;

  Comms({this.auth, this.email});

  @override
  _CommsState createState() => _CommsState();
}

class _CommsState extends State<Comms> {
  Contacts contacts;
  String addEmail;

  @override
  void initState() {
    super.initState();
    contacts = Contacts(userEmail: widget.email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Comms'),
      ),
      floatingActionButton: FloatingActionButton(child: Icon(Icons.add),onPressed: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                content: Container(
                  height: 220,
                  child: Column(
                    children: <Widget>[
                      Card(
                          elevation: 0,
                          borderOnForeground: false,
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          child: Container(
                              decoration:
                              BoxDecoration(color: Colors.deepOrangeAccent),
                              padding: EdgeInsets.fromLTRB(0, 20, 0, 20),
                              child: Center(
                                child: Text(
                                  'Add a Contact',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              ))),
                      Container(
                          width: 250,
                          child: Card(
                            child: Container(
                              padding: EdgeInsets.only(left: 15),
                              child: TextField(
                                keyboardType: TextInputType.emailAddress,
                                onChanged: (value) {
                                  addEmail = value;
                                },
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  labelText: 'Contact\'s Email',
                                ),
                              ),
                            ),
                            elevation: 20,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                          )),
                    ],
                  ),
                ),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel',
                          style: TextStyle(color: Colors.deepOrangeAccent))),
                  RaisedButton(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Text(
                      'Confirm & Send',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      contacts.addContact(addEmail);
                    },
                  )
                ],
              );
            });
      }),
    );
  }
}

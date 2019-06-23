import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';

import 'models/contacts_data.dart';
import 'services/auth_service.dart';

class ContactsPage extends StatefulWidget {
  final String email;
  final BaseAuth auth;

  ContactsPage({this.email, this.auth});

  @override
  _ContactsPageState createState() => _ContactsPageState();
}

enum DataStatus { NOT_DETERMINED, DETERMINED }

class _ContactsPageState extends State<ContactsPage> {
  DataStatus dataStatus = DataStatus.NOT_DETERMINED;
  Contacts contacts;
  List<Map<String, dynamic>> pendingContacts = [];

  @override
  void initState() {
    super.initState();
    contacts = Contacts(userEmail: widget.email);
    getListOfPendingContacts();
  }

  Future<Null> getListOfPendingContacts() async {
    QuerySnapshot snapshot = await contacts.getPendingContacts();
    snapshot.documents.forEach((f) {
      setState(() {
        pendingContacts.add(f.data);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _showListOfPendingContacts(),
    );
  }

  Widget _showListOfPendingContacts() {
    return ListView.builder(
        itemCount: pendingContacts.length,
        itemBuilder: (BuildContext context, int i) {
          return Card(
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(10),
                    child: CircularProfileAvatar(
                      pendingContacts[i]['contactImage'],
                      radius: 30,
                      borderWidth: 2,
                      borderColor: Colors.grey.withOpacity(.5),
                      cacheImage: true,
                    ),
                  ),
                  Expanded(
                    child: Row(
                      children: <Widget>[
                        Container(
                          child: Text(pendingContacts[i]['contactFirstName']),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Container(
                          child: Text(pendingContacts[i]['contactLastName']),
                        )
                      ],
                    ),
                  ),
                  Container(
                    width: 110,
                    padding: EdgeInsets.only(right: 10),
                    child: Row(
                      children: <Widget>[
                        SizedBox(
                          width: 50,
                          child: FlatButton(
                            child: Icon(
                              Icons.check,
                              color: Colors.green,
                            ),
                            onPressed: () {
                              contacts.updateStatus(
                                  pendingContacts[i]['contactEmail'],
                                  'accepted');
                              setState(() {
                                pendingContacts.removeAt(i);
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          width: 50,
                          child: Center(
                            child: FlatButton(
                              child: Icon(
                                Icons.clear,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                contacts.updateStatus(
                                    pendingContacts[i]['contactEmail'],
                                    'rejected');
                                setState(() {
                                  pendingContacts.removeAt(i);
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}

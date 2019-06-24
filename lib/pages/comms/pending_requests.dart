import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';

import '../../models/contacts_data.dart';
import '../../services/auth_service.dart';

class PendingRequests extends StatefulWidget {
  final String email;
  final BaseAuth auth;

  PendingRequests({this.email, this.auth});

  @override
  _PendingRequestsState createState() => _PendingRequestsState();
}

enum DataStatus { NOT_DETERMINED, DETERMINED }

class _PendingRequestsState extends State<PendingRequests> {
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
    return Scaffold(
      body: _showBody(),
    );
  }

  Widget _showBody() {
    return pendingContacts.length > 0
        ? Column(
            children: <Widget>[
              Expanded(child: _showListOfPendingContacts()),
            ],
          )
        : Center(
            child: Text(
              'No Pending Requests',
              style: TextStyle(
                  color: Colors.deepOrangeAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 25),
            ),
          );
  }

  Widget _showListOfPendingContacts() {
    return ListView.builder(
        itemCount: pendingContacts.length,
        itemBuilder: (BuildContext context, int i) {
          return pendingContacts[i]['requestedBy'] != widget.email
              ? Card(
                  elevation: 0,
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
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Container(
                                    child: Text(
                                        pendingContacts[i]['contactFirstName'], style: TextStyle(fontWeight: FontWeight.bold),),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Container(
                                    child: Text(
                                        pendingContacts[i]['contactLastName'], style: TextStyle(fontWeight: FontWeight.bold),),
                                  )
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Container(
                                    child: Text(
                                        'From: ${pendingContacts[i]['contactFrom']}', style: TextStyle(color: Colors.grey, fontSize: 10),),
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Container(
                                    child: Text(
                                      'Species: ${pendingContacts[i]['contactSpecies']}', style: TextStyle(color: Colors.grey, fontSize: 10),),
                                  ),
                                ],
                              ),
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
                                      contacts.removeContact(pendingContacts[i]['contactEmail']);
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
                )
              : Card(
                  elevation: 0,
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
                          child: Column(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Container(
                                    child: Text(
                                      pendingContacts[i]['contactFirstName'], style: TextStyle(fontWeight: FontWeight.bold),),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Container(
                                    child: Text(
                                      pendingContacts[i]['contactLastName'], style: TextStyle(fontWeight: FontWeight.bold),),
                                  )
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Container(
                                    child: Text(
                                      'From: ${pendingContacts[i]['contactFrom']}', style: TextStyle(color: Colors.grey, fontSize: 10),),
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  Container(
                                    child: Text(
                                      'Species: ${pendingContacts[i]['contactSpecies']}', style: TextStyle(color: Colors.grey, fontSize: 10),),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(right: 10),
                          child: Row(
                            children: <Widget>[
                              Text(
                                'Request Pending',
                                style: TextStyle(color: Colors.grey),
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

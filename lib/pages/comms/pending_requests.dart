import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../models/contacts_data.dart';
import '../../services/auth_service.dart';
import '../../widgets/header.dart';
import 'comms.dart';

class PendingRequests extends StatefulWidget {
  final String email;
  final BaseAuth auth;

  PendingRequests({this.email, this.auth});

  @override
  _PendingRequestsState createState() => _PendingRequestsState();
}

enum DataStatus { NOT_DETERMINED, DETERMINED }

class _PendingRequestsState extends State<PendingRequests> {
  TextEditingController editingController;
  IconData addIcon = MdiIcons.accountPlusOutline;
  DataStatus dataStatus = DataStatus.NOT_DETERMINED;
  Contacts contacts;
  List<Map<String, dynamic>> allUsers = [];
  List<Map<String, dynamic>> pendingContacts = [];

  @override
  void initState() {
    super.initState();
    editingController = TextEditingController(text: '');
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
    return Column(
      children: <Widget>[
        _header(
          'Search for Occupants',
        ),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                  color: Colors.deepOrangeAccent.withOpacity(0.4),
                  width: 2,
                  style: BorderStyle.solid),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                    color: Colors.white, offset: Offset(2, 0), blurRadius: 5)
              ]),
          margin: EdgeInsets.only(left: 15, right: 15, top: 5),
          child: TextField(
            controller: editingController,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.only(
                left: 5,
                top: 10,
                bottom: 10,
              ),
              border: InputBorder.none,
            ),
            onChanged: (value) async {
              QuerySnapshot snapshot = await contacts.getAllUsers(value);
              print(snapshot.documents.length);
              if (snapshot.documents.length > 0) {
                snapshot.documents.forEach((f) {
                  setState(() {
                    allUsers.add(f.data);
                  });
                });
              } else {
                setState(() {
                  allUsers.clear();
                });
              }
            },
          ),
        ),
        allUsers.length > 0
            ? Expanded(
                child: _showSearchResults(),
              )
            : SizedBox(),
        _header(
          'Pending Requests',
        ),
        Expanded(
            child: pendingContacts.length > 0
                ? _showListOfPendingContacts()
                : Center(
                    child: Text(
                      'No pending requests',
                      style: TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  )),
      ],
    );
  }

  Widget _header(String header) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
      child: Center(
          child: Text(
            header,
            style: TextStyle(
                color: Colors.black26,
                fontSize: 25,
                fontWeight: FontWeight.bold),
          )),
    );
  }

  Widget _showSearchResults() {
    return ListView.builder(
        itemCount: allUsers.length,
        itemBuilder: (BuildContext context, int i) {
          return Card(
            elevation: 0,
            child: Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(10),
                    child: CircularProfileAvatar(
                      allUsers[i]['profilePic'],
                      radius: 30,
                      borderWidth: 2,
                      borderColor: Colors.grey.withOpacity(.5),
                      cacheImage: true,
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => _showContactInfo(allUsers, i),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                child: Text(
                                  allUsers[i]['fullName'],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Container(
                                child: Text(
                                  'From: ${allUsers[i]['mother_planet']}',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Container(
                                child: Text(
                                  'Species: ${allUsers[i]['species']}',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 110,
                    padding: EdgeInsets.only(right: 10),
                    child: Row(
                      children: <Widget>[
                        FlatButton(
                          child: Icon(
                            addIcon,
                            color: Colors.green,
                          ),
                          onPressed: () async {
                            contacts.addContact(allUsers[i]['email']);
                            editingController.clear();
                            print(allUsers[i]);
                            setState(() {
                              allUsers[i]['requestedBy'] = widget.email;
                              pendingContacts.add(allUsers[i]);
                              allUsers.clear();
                            });
                          },
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
                            pendingContacts[i]['profilePic'],
                            radius: 30,
                            borderWidth: 2,
                            borderColor: Colors.grey.withOpacity(.5),
                            cacheImage: true,
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => _showContactInfo(allUsers, i),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Container(
                                      child: Text(
                                        pendingContacts[i]['firstName'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Container(
                                      child: Text(
                                        pendingContacts[i]['lastName'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Container(
                                      child: Text(
                                        'From: ${pendingContacts[i]['mother_planet']}',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 10),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Container(
                                      child: Text(
                                        'Species: ${pendingContacts[i]['species']}',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 10),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
                                      contacts.removeContact(
                                          pendingContacts[i]['contactEmail']);
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
                            pendingContacts[i]['profilePic'],
                            radius: 30,
                            borderWidth: 2,
                            borderColor: Colors.grey.withOpacity(.5),
                            cacheImage: true,
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => _showContactInfo(pendingContacts, i),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    Container(
                                      child: Text(
                                        pendingContacts[i]['firstName'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Container(
                                      child: Text(
                                        pendingContacts[i]['lastName'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Container(
                                      child: Text(
                                        'From: ${pendingContacts[i]['mother_planet']}',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 10),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: <Widget>[
                                    Container(
                                      child: Text(
                                        'Species: ${pendingContacts[i]['species']}',
                                        style: TextStyle(
                                            color: Colors.grey, fontSize: 10),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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

  void _showContactInfo(List<Map<String, dynamic>> typeOfList, int i) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return ListView(
            children: <Widget>[
              Card(
                clipBehavior: Clip.antiAlias,
                elevation: 15,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: CachedNetworkImage(
                  placeholder: (context, url) =>
                      SpinKitDualRing(color: Colors.deepOrangeAccent),
                  imageUrl: typeOfList[i]['profilePic'],
                  height: 150,
                  fit: BoxFit.cover,
                ),
              ),
              _header('Contact Info'),
              Card(
                elevation: 15,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
                child: Container(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: 10,
                          ),
                          Text('Full Name: '),
                          Text(
                            '${typeOfList[i]['firstName']} ${typeOfList[i]['lastName']}',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                          margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
                          child: Divider(height: 3, color: Colors.black45)),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: 10,
                          ),
                          Text('Date of Birth: '),
                          Text(
                            '${typeOfList[i]['dateOfBirth']}',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                          margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
                          child: Divider(height: 3, color: Colors.black45)),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: 10,
                          ),
                          Text('Gender: '),
                          Text(
                            '${typeOfList[i]['gender']}',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text('Species: '),
                          Text(
                            '${typeOfList[i]['species']}',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          )
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                          margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
                          child: Divider(height: 3, color: Colors.black45)),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: 10,
                          ),
                          Text('Citizenship Status: '),
                          typeOfList[i]['martian'] == false
                              ? Text(
                                  'Non-Martian',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.red),
                                )
                              : Text(
                                  'Martian',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green),
                                ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                          margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
                          child: Divider(height: 3, color: Colors.black45)),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: 10,
                          ),
                          Text('Planet of Origin: '),
                          Text(
                            '${typeOfList[i]['mother_planet']}',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                          margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
                          child: Divider(height: 3, color: Colors.black45)),
                      SizedBox(
                        height: 15,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            width: 10,
                          ),
                          Text('Reason For Visit: '),
                          Text(
                            '${typeOfList[i]['reason']}',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 15,
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
        });
  }
}

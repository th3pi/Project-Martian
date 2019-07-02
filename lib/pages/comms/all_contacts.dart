import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/contacts_data.dart';
import '../../services/auth_service.dart';
import 'message.dart';

class AllContacts extends StatefulWidget {
  final String email;
  final BaseAuth auth;

  AllContacts({this.email, this.auth});

  @override
  _AllContactsState createState() => _AllContactsState();
}

class _AllContactsState extends State<AllContacts>
    with SingleTickerProviderStateMixin {
  Contacts _contacts;
  AnimationController _controller;
  List<Map<String, dynamic>> allContacts = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _contacts = Contacts(userEmail: widget.email);
    Firestore.instance
        .collection('users')
        .document(widget.email)
        .collection('contacts')
        .where('status', isEqualTo: 'accepted')
        .snapshots()
        .listen((data) {
      data.documentChanges.forEach((f) {
        if (!allContacts.contains(f.document.data)) {
          allContacts.add(f.document.data);
        }
      });
    });
  }

  Future<Null> getAllContacts() async {
    allContacts.clear();
    final snapshot = await _contacts.getAllContacts();
    snapshot.documents.forEach((f) {
      setState(() {
        allContacts.add(f.data);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return allContacts.length > 0
        ? ListView.builder(
            itemCount: allContacts.length,
            itemBuilder: (BuildContext context, int i) {
              return Card(
                elevation: 0,
                child: Container(
                  padding: EdgeInsets.only(top: 5, bottom: 5),
                  child: ListTile(
                    leading: CircularProfileAvatar(
                      allContacts[i]['profilePic'],
                      radius: 30,
                      cacheImage: true,
                      borderColor: Colors.grey,
                      borderWidth: 2,
                    ),
                    title: InkWell(
                      onTap: () => _showContactInfo(allContacts, i),
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                child: Text(
                                  allContacts[i]['firstName'],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Container(
                                child: Text(
                                  allContacts[i]['lastName'],
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              )
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Container(
                                child: Text(
                                  'From: ${allContacts[i]['mother_planet']}',
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
                                  'Species: ${allContacts[i]['species']}',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 10),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    trailing: PopupMenuButton(
                        onSelected: (value) {
                          switch (value) {
                            case 1:
                              _showContactInfo(allContacts, i);
                              break;
                            case 2:
                              _contacts.removeContact(
                                  allContacts[i]['contactEmail']);
                              setState(() {
                                allContacts.removeAt(i);
                              });
                              break;
                            case 3:
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MessageScreen(
                                            auth: widget.auth,
                                            email: widget.email,
                                            to: allContacts[i]['contactEmail'],
                                            name:
                                                '${allContacts[i]['fullName']}',
                                          )));
                          }
                        },
                        itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 3,
                                child: Text(
                                  'Send Message',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                              PopupMenuItem(
                                value: 1,
                                child: Text(
                                  'Show Info',
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),
                              PopupMenuItem(
                                value: 2,
                                child: Text(
                                  'Disconnect Comms',
                                  style: TextStyle(
                                      fontSize: 15, color: Colors.red),
                                ),
                              ),
                            ]),
                  ),
                ),
              );
            })
        : Center(
            child: Text(
              'No comms established yet',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          );
  }

  Widget _header(String header) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 10, 0, 5),
      child: Center(
          child: Text(
        header,
        style: TextStyle(
            color: Colors.black26, fontSize: 25, fontWeight: FontWeight.bold),
      )),
    );
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

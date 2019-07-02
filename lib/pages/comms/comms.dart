import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:project_martian/widgets/drawer.dart';
import 'package:animator/animator.dart';

import '../../models/comms_data.dart';
import '../../models/contacts_data.dart';
import '../../services/auth_service.dart';
import 'package:project_martian/pages/comms/pending_requests.dart';
import 'all_contacts.dart';
import 'message.dart';

class Comms extends StatefulWidget {
  final String email;
  final BaseAuth auth;
  final int tab;

  Comms({this.auth, this.email, this.tab});

  @override
  _CommsState createState() => _CommsState();
}

class _CommsState extends State<Comms> with SingleTickerProviderStateMixin {
  TabController tabController;
  String appBarTitle = 'Comms';
  Contacts contacts;
  CommsData commsData;
  String addEmail;
  List<Map<String, dynamic>> allMessages = [];

  @override
  void initState() {
    super.initState();
    contacts = Contacts(userEmail: widget.email);
    tabController = TabController(length: 3, vsync: this);
    commsData = CommsData(email: widget.email, auth: widget.auth);
    getAllMessages();
  }

  void getAllMessages() async {
    commsData.getAllMessages().then((value) {
      value.documents.forEach((f) {
        setState(() {
          allMessages.add(f.data);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    void detectChange() {
      if (tabController.index == 0) {
        setState(() {
          appBarTitle = 'Comms';
        });
      } else if (tabController.index == 1) {
        setState(() {
          appBarTitle = 'Contacts';
        });
      } else if (tabController.index == 2) {
        setState(() {
          appBarTitle = 'Pending Requests';
        });
      }
    }

    tabController.addListener(detectChange);

    return Scaffold(
      drawer: CustomDrawer(
        email: widget.email,
        auth: widget.auth,
      ),
      appBar: AppBar(
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (value) {
              switch (value) {
                case 1:
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext) => Comms(
                                auth: widget.auth,
                                email: widget.email,
                              )));
              }
            },
            itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 1,
                    child: Text('Refresh'),
                  )
                ],
          )
        ],
        elevation: 0,
        title: Text(
          appBarTitle,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(controller: tabController, tabs: <Widget>[
          Tab(
            icon: Icon(MdiIcons.forumOutline),
          ),
          Tab(
            icon: Icon(MdiIcons.contacts),
          ),
          Tab(
            icon: Icon(MdiIcons.accountPlus),
          )
        ]),
      ),
      body: TabBarView(
        children: <Widget>[
          _messageCard(),
          AllContacts(
            email: widget.email,
            auth: widget.auth,
          ),
          PendingRequests(
            auth: widget.auth,
            email: widget.email,
          )
        ],
        controller: tabController,
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
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
                                  decoration: BoxDecoration(
                                      color: Colors.deepOrangeAccent),
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
                              style:
                                  TextStyle(color: Colors.deepOrangeAccent))),
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

  Widget _messageCard() {
    return allMessages.length > 0
        ? ListView.builder(
            itemCount: allMessages.length,
            itemBuilder: (BuildContext context, int i) {
              return Card(
                elevation: 0,
                child: Container(
                  padding: EdgeInsets.only(top: 5, bottom: 5),
                  child: ListTile(
                    leading: CircularProfileAvatar(
                      allMessages[i]['profilePic'],
                      radius: 30,
                      cacheImage: true,
                      borderColor: Colors.grey,
                      borderWidth: 2,
                    ),
                    title: InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MessageScreen(
                                      profilePic: allMessages[i]['profilePic'],
                                      auth: widget.auth,
                                      email: widget.email,
                                      to: allMessages[i]['receiverEmail'],
                                      name: allMessages[i]['name'],
                                    )));
                      },
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                child: Text(
                                  allMessages[i]['name'],
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
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
                                  '${allMessages[i]['lastMessage']}',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 15),
                                ),
                              ),
                              SizedBox(
                                child: Icon(
                                  Icons.radio_button_unchecked,
                                  size: 3,
                                ),
                                width: 20,
                              ),
                              Container(
                                child: Text(
                                  DateTime.now()
                                              .difference(DateTime.parse(
                                                  allMessages[i][
                                                      'dateTimeOfLastMessage']))
                                              .inHours >
                                          0
                                      ? '${DateTime.now().difference(DateTime.parse(allMessages[i]['dateTimeOfLastMessage'])).inHours}h ago'
                                      : (DateTime.now()
                                                  .difference(DateTime.parse(
                                                      allMessages[i][
                                                          'dateTimeOfLastMessage']))
                                                  .inMinutes >
                                              0
                                          ? '${DateTime.now().difference(DateTime.parse(allMessages[i]['dateTimeOfLastMessage'])).inMinutes}m ago'
                                          : (DateTime.now()
                                                      .difference(DateTime.parse(
                                                          allMessages[i]
                                                              ['dateTimeOfLastMessage']))
                                                      .inHours >
                                                  24
                                              ? '${allMessages[i]['formattedDateTime']}'
                                              : '${DateTime.now().difference(DateTime.parse(allMessages[i]['dateTimeOfLastMessage'])).inSeconds}s ago')),
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 13),
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
                              break;
                            case 2:
                              break;
                          }
                        },
                        itemBuilder: (context) => [
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
}

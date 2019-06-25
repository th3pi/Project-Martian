import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:project_martian/widgets/drawer.dart';

import '../../models/contacts_data.dart';
import '../../services/auth_service.dart';
import 'package:project_martian/pages/comms/pending_requests.dart';

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
  String addEmail;

  @override
  void initState() {
    super.initState();
    contacts = Contacts(userEmail: widget.email);
    tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    if(widget.tab != null){
      tabController.animateTo(widget.tab, duration: Duration(milliseconds: 200));
    }
    void detectChange(){
      if(tabController.index == 1) {
        setState(() {
          appBarTitle = 'Pending Requests';
        });
      }
      else if(tabController.index == 0){
        setState(() {
          appBarTitle = 'Comms';
        });
      }
    }
    tabController.addListener(detectChange);

    return Scaffold(
      drawer: CustomDrawer(email: widget.email, auth: widget.auth,),
      appBar: AppBar(
        elevation: 0,
        title: Text(appBarTitle, style: TextStyle(fontWeight: FontWeight.bold),),
        bottom: TabBar(controller: tabController, tabs: <Widget>[
          Tab(
            icon: Icon(MdiIcons.forumOutline),
          ),
          Tab(
            icon: Icon(MdiIcons.accountPlus),
          )
        ]),
      ),
      body: TabBarView(
        children: <Widget>[
          _placeHolderText(),
          PendingRequests(
            auth: widget.auth,
            email: widget.email,
          )
        ],
        controller: tabController,
      ),
      floatingActionButton:
          FloatingActionButton(child: Icon(Icons.add), onPressed: () {
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

  Widget _placeHolderText() {
    return Center(
      child: Text('Test1'),
    );
  }

  Widget _placeHolderText2() {
    return Center(
      child: Text('Test2'),
    );
  }
}

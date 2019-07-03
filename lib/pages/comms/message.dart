import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';

import '../../services/auth_service.dart';
import '../../models/comms_data.dart';
import '../../models/user_data.dart';

class MessageScreen extends StatefulWidget {
  final String email;
  final BaseAuth auth;
  final String to;
  final String name;
  final String profilePic;

  MessageScreen({this.auth, this.email, this.to, this.name, this.profilePic});

  @override
  _MessageScreenState createState() => _MessageScreenState();
}

enum DataStatus { DETERMINED, NOT_DETERMINED }

class _MessageScreenState extends State<MessageScreen> {
  DataStatus dataStatus = DataStatus.NOT_DETERMINED;
  ScrollController scrollController = ScrollController();
  TextEditingController editingController;
  CommsData commsData;
  User user;
  List<Map<String, dynamic>> messages = [];
  Map<String, dynamic> userData;

  @override
  void initState() {
    super.initState();
    editingController = TextEditingController(text: '');
    commsData = CommsData(auth: widget.auth, email: widget.email);
    Firestore.instance
        .collection('users')
        .document(widget.email)
        .collection('communications')
        .document(widget.to)
        .collection('messages')
        .snapshots()
        .listen((data) {
      data.documentChanges.forEach((f) {
        dataStatus =
            f == null ? DataStatus.NOT_DETERMINED : DataStatus.DETERMINED;
        messages.add(f.document.data);
        scrollController.jumpTo(0.0);
      });
    });
  }

  void getMessage() async {
    commsData.getAllContactMessages(widget.to).then((value) {
      value.documents.forEach((f) {
        setState(() {
          messages.add(f.data);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _showBody(),
    );
  }

  Widget _showBody() {
    return Column(
      children: <Widget>[
        Expanded(child: _allMessages()),
        _sendMessageField(),
      ],
    );
  }

  Widget _allMessages() {
    return StreamBuilder(
      stream: Firestore.instance
          .collection('users')
          .document(widget.email)
          .collection('communications')
          .document(widget.to)
          .collection('messages')
          .orderBy('dateTime', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        return ListView.builder(
            reverse: true,
            shrinkWrap: true,
            controller: scrollController,
            itemCount: snapshot.data.documents.length,
            itemBuilder: (context, i) {
              return snapshot.data.documents[i]['type'] == 'sent'
                  ? Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      elevation: 0,
                      margin: EdgeInsets.only(
                          left: 40, top: 5, bottom: 5, right: 5),
                      color: Colors.deepOrangeAccent,
                      child: Container(
                        padding:
                            EdgeInsets.only(right: 15, top: 25, bottom: 25),
                        child: Row(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(left: 10),
                              child: Text(
                                snapshot.data.documents[i]['formattedTime'],
                                textAlign: TextAlign.left,
                                style: TextStyle(fontSize: 10, color: Colors.white),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                snapshot.data.documents[i]['message'],
                                textAlign: TextAlign.right,
                                style: TextStyle(color: Colors.white),

                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      margin: EdgeInsets.only(
                          right: 40, top: 5, bottom: 5, left: 5),
                      color: Colors.white70,
                      child: Container(
                        padding: EdgeInsets.only(left: 15, top: 20, bottom: 20),
                        child: Row(
                          children: <Widget>[
                            Container(
                              child: CircularProfileAvatar(
                                widget.profilePic,
                                radius: 20,
                                cacheImage: true,
                                borderColor: Colors.black54,
                                borderWidth: 2,
                              ),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            Expanded(
                              child: Text(
                                snapshot.data.documents[i]['message'],
                                textAlign: TextAlign.left,
                                style: TextStyle(color: Colors.black),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(right: 10),
                              child: Text(
                                snapshot.data.documents[i]['formattedTime'],
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 10),
                              ),
                            ),
                          ],
                        ),
                      ));
            });
      },
    );
  }

  Widget _sendMessageField() {
    return Row(
      children: <Widget>[
        Expanded(
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
            onChanged: (value) {},
            onSubmitted: (value) {
              commsData.sendMessage(widget.to, editingController.text);
            },
          ),
        ),
        IconButton(
          onPressed: () {
            if(editingController.text != '') {
              commsData.sendMessage(widget.to, editingController.text);
              editingController.clear();
            }
          },
          icon: Icon(Icons.send, color: Colors.deepOrangeAccent,),
        )
      ],
    );
  }
}

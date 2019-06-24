import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../widgets/id_card.dart';
import '../../widgets/add_id_card.dart';

class PassportManager extends StatefulWidget {
  final List<Map<String, dynamic>> listOfIds;
  final String email;
  final BaseAuth auth;

  PassportManager({this.listOfIds, this.email, this.auth});

  @override
  State<StatefulWidget> createState() {
    return _PassportManagerState();
  }
}

enum DataStatus { NOT_DETERMINED, DETERMINED }

class _PassportManagerState extends State<PassportManager> {

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: EdgeInsets.fromLTRB(7, 15, 7, 0),
        itemCount: widget.listOfIds.length + 1,
        itemBuilder: (BuildContext context, int i) {
          return i == widget.listOfIds.length
              ? AddIdCard(
                  email: widget.email,
                  auth: widget.auth,
                  scale: 1,
                )
              : IdCard(
                  scale: 1,
                  auth: widget.auth,
                  email: widget.email,
                  callingFrom: 'profile',
                  index: i,
                );
        });
  }
}

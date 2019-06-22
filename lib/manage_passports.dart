import 'package:flutter/material.dart';

import 'services/auth_service.dart';
import 'models/planet_data.dart';
import 'widgets/id_card.dart';
import 'widgets/add_id_card.dart';

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
  DataStatus dataStatus = DataStatus.NOT_DETERMINED;
  PlanetData planetData;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(7, 35, 7, 0),
      child: ListView.builder(
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
          }),
    );
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      dataStatus = widget.listOfIds == null
          ? DataStatus.NOT_DETERMINED
          : DataStatus.DETERMINED;
    });
  }

}

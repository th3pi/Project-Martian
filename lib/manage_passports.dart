import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'services/auth_service.dart';
import 'widgets/id_card.dart';
import 'forms/id_form.dart';
import 'models/planet_data.dart';

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

enum DataStatus {NOT_DETERMINED, DETERMINED}

class _PassportManagerState extends State<PassportManager> {
  DataStatus dataStatus  = DataStatus.NOT_DETERMINED;
  PlanetData planetData;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(7, 35, 7, 0),
      child: ListView.builder(itemCount: widget.listOfIds.length+1, itemBuilder: (BuildContext context, int i){
        return i == 0 ? _showAddIdCard() : _idCards(i-1);
      }),
    );
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      dataStatus = widget.listOfIds == null ? DataStatus.NOT_DETERMINED : DataStatus.DETERMINED;
    });
  }

  Widget _showAddIdCard() {
    return InkWell(
      splashColor: Colors.deepOrangeAccent,
      onTap: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext) => IdForm(
                email: widget.email,
                auth: widget.auth,
                from: 'profile',
              ))),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: EdgeInsets.only(bottom: 20),
          height: 200,
          width: 800,
          child: Card(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 10,
            clipBehavior: Clip.antiAlias,
            child: Center(
              child: Icon(
                Icons.add_circle_outline,
                size: 50,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _idCards(int index) {
    return Align(
      child: Container(
        padding: EdgeInsets.only(bottom: 20),
        height: 200,
        width: 800,
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          child: InkWell(
            onTap: () {
            },
            child: Container(
              decoration: BoxDecoration(
                  gradient: _colorPicker(widget.listOfIds[index]['planetName'])),
              child: dataStatus == DataStatus.NOT_DETERMINED
                  ? SpinKitDualRing(color: Colors.deepOrangeAccent)
                  : Container(
                child: Row(
                  children: <Widget>[
                    Flexible(
                      fit: FlexFit.tight,
                      flex: 2,
                      child: QrImage(
                        gapless: true,
                        backgroundColor: Colors.white,
                        data: 'No Data',
                        size: 250,
                      ),
                    ),
                    Flexible(
                      flex: 3,
                      child: Container(
                        padding: EdgeInsets.only(left: 10),
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Container(
                                    padding:
                                    EdgeInsets.fromLTRB(0, 15, 0, 5),
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          'First Name',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            shadows: [
                                              Shadow(
                                                  blurRadius: 10,
                                                  color: Colors.black87)
                                            ],
                                          ),
                                        ),
                                        Container(
                                          child: Text(
                                            widget.listOfIds[index]
                                            ['planetFirstName'],
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              shadows: [
                                                Shadow(
                                                    blurRadius: 10,
                                                    color: Colors.black87)
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                                Container(
                                    padding:
                                    EdgeInsets.fromLTRB(20, 15, 0, 5),
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          'Last Name',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            shadows: [
                                              Shadow(
                                                  blurRadius: 10,
                                                  color: Colors.black87)
                                            ],
                                          ),
                                        ),
                                        Container(
                                          child: Text(
                                            widget.listOfIds[index]
                                            ['planetLastName'],
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              shadows: [
                                                Shadow(
                                                    blurRadius: 10,
                                                    color: Colors.black87)
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Container(
                                    padding:
                                    EdgeInsets.fromLTRB(0, 15, 0, 5),
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          'Planetary ID',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            shadows: [
                                              Shadow(
                                                  blurRadius: 10,
                                                  color: Colors.black87)
                                            ],
                                          ),
                                        ),
                                        Container(
                                          child: Text(
                                            widget.listOfIds[index]
                                            ['planetaryId'],
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              shadows: [
                                                Shadow(
                                                    blurRadius: 10,
                                                    color: Colors.black87)
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                                Container(
                                    padding:
                                    EdgeInsets.fromLTRB(20, 15, 0, 5),
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          'Planet Name',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            shadows: [
                                              Shadow(
                                                  blurRadius: 10,
                                                  color: Colors.black87)
                                            ],
                                          ),
                                        ),
                                        Container(
                                          alignment:
                                          Alignment.centerRight,
                                          padding:
                                          EdgeInsets.only(left: 5),
                                          child: Text(
                                            widget.listOfIds[index]
                                            ['planetName'],
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              shadows: [
                                                Shadow(
                                                    blurRadius: 10,
                                                    color: Colors.black87)
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Container(
                                    padding:
                                    EdgeInsets.fromLTRB(0, 15, 0, 5),
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          'ID Type',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            shadows: [
                                              Shadow(
                                                  blurRadius: 10,
                                                  color: Colors.black87)
                                            ],
                                          ),
                                        ),
                                        Container(
                                          child: Text(
                                            widget.listOfIds[index]['idType'],
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              shadows: [
                                                Shadow(
                                                    blurRadius: 10,
                                                    color: Colors.black87)
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                                Container(
                                    padding:
                                    EdgeInsets.fromLTRB(20, 15, 0, 5),
                                    child: Column(
                                      children: <Widget>[
                                        Text(
                                          'Date of Expiration',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            shadows: [
                                              Shadow(
                                                  blurRadius: 10,
                                                  color: Colors.black87)
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding:
                                          EdgeInsets.only(left: 5),
                                          child: Text(
                                            widget.listOfIds[index]
                                            ['dateOfExpiration'],
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              shadows: [
                                                Shadow(
                                                    blurRadius: 10,
                                                    color: Colors.black87)
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
  String _planetImagePicker(String planetName) {
    switch (planetName.toLowerCase()) {
      case 'mercury':
        return 'assets/mercury.jpg';
        break;
      case 'mars':
        return 'assets/mars.jpg';
        break;
      case 'venus':
        return 'assets/venus.jpg';
        break;
      case 'earth':
        return 'assets/earth.jpg';
        break;
      case 'jupiter':
        return 'assets/jupiter.jpg';
        break;
      case 'neptune':
        return 'assets/neptune.jpg';
        break;
      case 'saturn':
        return 'assets/saturn.jpg';
        break;
      case 'uranus':
        return 'assets/uranus.jpg';
        break;
      default:
        return 'assets/space.jpg';
        break;
    }
  }

  LinearGradient _colorPicker(String planetName) {
    switch (planetName) {
      case 'Mercury':
        return LinearGradient(
            begin: FractionalOffset.topRight,
            end: FractionalOffset.bottomLeft,
            colors: [Colors.orangeAccent, Colors.deepOrangeAccent]);
        break;
      case 'Mars':
        return LinearGradient(
            begin: FractionalOffset.topRight,
            end: FractionalOffset.bottomLeft,
            colors: [
              Colors.redAccent,
              Colors.deepOrangeAccent,
              Colors.orangeAccent
            ]);
        break;
      case 'Venus':
        return LinearGradient(
            begin: FractionalOffset.topRight,
            end: FractionalOffset.bottomLeft,
            colors: [Colors.grey, Colors.blueGrey]);
        break;
      case 'Earth':
        return LinearGradient(
            begin: FractionalOffset.topRight,
            end: FractionalOffset.bottomLeft,
            colors: [Colors.blueGrey, Colors.green]);
        break;
      case 'Jupiter':
        return LinearGradient(
            begin: FractionalOffset.topRight,
            end: FractionalOffset.bottomLeft,
            colors: [Colors.grey, Colors.brown]);
        break;
      case 'Neptune':
        return LinearGradient(
            begin: FractionalOffset.topRight,
            end: FractionalOffset.bottomLeft,
            colors: [Colors.blue, Colors.blueAccent]);
        break;
      case 'Saturn':
        return LinearGradient(
            begin: FractionalOffset.topRight,
            end: FractionalOffset.bottomLeft,
            colors: [Colors.deepOrangeAccent, Colors.brown]);
        break;
      case 'Uranus':
        return LinearGradient(
            begin: FractionalOffset.topRight,
            end: FractionalOffset.bottomLeft,
            colors: [Colors.blueAccent, Colors.lightBlue]);
        break;
      default:
        return LinearGradient(
            begin: FractionalOffset.topRight,
            end: FractionalOffset.bottomLeft,
            colors: [Colors.grey, Colors.blueGrey]);
        break;
    }
  }
}

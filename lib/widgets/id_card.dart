import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:math';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../services/authentication_check.dart';
import '../services/auth_service.dart';
import '../forms/id_form.dart';
import '../models/planet_data.dart';

class IdCard extends StatefulWidget {
  final String email;
  final BaseAuth auth;

  IdCard({this.email, this.auth});

  @override
  State<StatefulWidget> createState() {
    return _IdCardState();
  }
}

enum DataStatus { DETERMINED, NOT_DETERMINED }

class _IdCardState extends State<IdCard> {
  DataStatus dataStatus = DataStatus.NOT_DETERMINED;
  PageController pageController;
  int currentPage = 0, numOfIds;
  double page = 2.0;
  double scaleFraction = 0.9,
      fullScale = 1.0,
      pagerHeight = 200,
      viewportFraction = 0.95;
  List<Map<String, dynamic>> listOfIds = [];

  @override
  Widget build(BuildContext context) {
    return _showIdCards();
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController(
        initialPage: currentPage, viewportFraction: viewportFraction);
    Firestore.instance
        .collection('users')
        .document(widget.email)
        .collection('planetary_ids')
        .snapshots()
        .listen((snapshot) {
      dataStatus =
          snapshot == null ? DataStatus.NOT_DETERMINED : DataStatus.DETERMINED;
      if (snapshot != null) {
        snapshot.documents.forEach((doc) {
          listOfIds.add(doc.data);
          setState(() {
            numOfIds = listOfIds.length + 1;
            currentPage = 0;
          });
        });
      }
    });
  }

  Widget _idCards(int index, double scale) {
    return Align(
      child: Container(
        padding: EdgeInsets.only(bottom: 20),
        height: pagerHeight * scale,
        width: 800,
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          child: InkWell(
            onTap: () {
              _cardInfoBottomSheet(index, context);
            },
            child: Container(
              decoration: BoxDecoration(
                  gradient: _colorPicker(listOfIds[index]['planetName'])),
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
                              data: widget.email,
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
                                                  listOfIds[index]
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
                                                  listOfIds[index]
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
                                                  listOfIds[index]
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
                                                  listOfIds[index]
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
                                                  listOfIds[index]['idType'],
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
                                                  listOfIds[index]
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

  Widget _showAddIdCard(double scale) {
    return InkWell(
      splashColor: Colors.deepOrangeAccent,
      onTap: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext) => IdForm(
                    email: widget.email,
                    auth: widget.auth,
                  ))),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          padding: EdgeInsets.only(bottom: 20),
          height: pagerHeight * scale,
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

  Widget _showIdCards() {
    return Container(
      height: 200,
      child: dataStatus == DataStatus.NOT_DETERMINED
          ? SpinKitDualRing(
              color: Colors.deepOrangeAccent,
            )
          : ListView(
              physics: BouncingScrollPhysics(),
              children: <Widget>[
                Container(
                  height: pagerHeight,
                  child: NotificationListener<ScrollNotification>(
                    child: PageView.builder(
                      itemBuilder: (context, index) {
                        final scale = max(
                            scaleFraction,
                            (fullScale - (index - page).abs()) +
                                viewportFraction);
                        return index == numOfIds - 1
                            ? _showAddIdCard(scale)
                            : _idCards(index, scale);
                      },
                      itemCount: numOfIds,
                      controller: pageController,
                      onPageChanged: (pos) {
                        setState(() {
                          currentPage = pos;
                        });
                      },
                      physics: AlwaysScrollableScrollPhysics(),
                    ),
                    onNotification: (ScrollNotification notification) {
                      if (notification is ScrollUpdateNotification) {
                        setState(() {
                          page = pageController.page;
                        });
                      }
                    },
                  ),
                ),
              ],
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

  void _cardInfoBottomSheet(index, context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
            decoration: BoxDecoration(
                gradient:
                    LinearGradient(colors: [Colors.white30, Colors.white])),
            child:
                ListView(physics: ClampingScrollPhysics(), children: <Widget>[
              Column(
                children: <Widget>[
                  Card(
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    elevation: 5,
                    child: Image.asset(
                      _planetImagePicker(listOfIds[index]['planetName']),
                      height: 150,
                      width: 1000,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Card(
                    //Full Name card
                    elevation: 5,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      width: double.infinity,
                      child: Row(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(left: 5),
                            child: Text(
                              'Local Name: ',
                            ),
                          ),
                          Text(
                            '${listOfIds[index]['planetFirstName']} ${listOfIds[index]['planetLastName']}',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    // Planet Name Card
                    elevation: 5,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      width: double.infinity,
                      child: Row(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(left: 5),
                            child: Text(
                              'Planet Name: ',
                            ),
                          ),
                          Text(
                            listOfIds[index]['planetName'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 50),
                            child: Text(
                              'ID Type: ',
                            ),
                          ),
                          Text(
                            listOfIds[index]['idType'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    // Planet Name Card
                    elevation: 5,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      width: double.infinity,
                      child: Row(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(left: 5),
                            child: Text(
                              'ID Issued On: ',
                            ),
                          ),
                          Text(
                            listOfIds[index]['dateIssued'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 25),
                            child: Text(
                              'Date of Expiration: ',
                            ),
                          ),
                          Text(
                            listOfIds[index]['dateOfExpiration'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    // Planet Name Card
                    elevation: 5,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      width: double.infinity,
                      child: Row(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(left: 5),
                            child: Text(
                              'Planetary ID: ',
                            ),
                          ),
                          Text(
                            listOfIds[index]['planetaryId'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    // Planet Name Card
                    elevation: 5,
                    child: Container(
                      padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                      width: double.infinity,
                      child: Row(
                        children: <Widget>[
                          Container(
                            padding: EdgeInsets.only(left: 5),
                            child: Text(
                              'Criminal Record: ',
                            ),
                          ),
                          Text(
                            listOfIds[index]['criminalRecord'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: EdgeInsets.only(left: 50),
                            child: Text(
                              'Flying License: ',
                            ),
                          ),
                          Text(
                            listOfIds[index]['flyingLicense'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)),
                    child: Text(
                      'Delete ID',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    color: Colors.red,
                    onPressed: listOfIds[index]['planetName'] == 'Mars'
                        ? null
                        : () {
                            PlanetData(
                                    email: widget.email,
                                    planetName: listOfIds[index]['planetName'])
                                .deleteId(listOfIds[index]['planetName']);
                            Navigator.pop(context);
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext) =>
                                        CheckAuthentication(
                                          auth: widget.auth,
                                          userId: widget.email,
                                        )));
                          },
                  )
                ],
              ),
            ]),
          );
        });
  }
}

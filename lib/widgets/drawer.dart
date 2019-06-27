import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter/material.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:expandable/expandable.dart';

import '../models/user_data.dart';
import '../services/auth_service.dart';
import '../pages/profile/profile.dart';
import '../pages/bank/bank.dart';
import '../pages/comms/comms.dart';
import '../services/authentication_check.dart';
import '../pages/home.dart';

enum DataStatus { DETERMINED, NOT_DETERMINED }

class CustomDrawer extends StatefulWidget {
  final String email;
  final BaseAuth auth;

  CustomDrawer({this.email, this.auth});

  @override
  _CustomDrawerState createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  User user;
  Map<String, dynamic> userData;
  DataStatus dataStatus = DataStatus.NOT_DETERMINED;

  @override
  void initState() {
    super.initState();
    user = User(email: widget.email);
    user.getAllData().then((value) {
      if (value != null) {
        setState(() {
          dataStatus = DataStatus.DETERMINED;
          userData = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(color: Colors.deepOrange),
                  child: Container(
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            dataStatus == DataStatus.DETERMINED
                                ? CircularProfileAvatar(
                              userData['profilePic'],
                              radius: 30,
                              borderWidth: 2,
                              borderColor: Colors.white.withOpacity(.5),
                              cacheImage: true,
                            ) : SpinKitDualRing(color: Colors.deepOrangeAccent,),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              dataStatus == DataStatus.NOT_DETERMINED
                                  ? 'Loading...'
                                  : '${userData['firstName']} ${userData['lastName']}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              'uMail  ',
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              dataStatus == DataStatus.NOT_DETERMINED
                                  ? 'Loading...'
                                  : '${userData['email']}',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              'GSID  ',
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              dataStatus == DataStatus.NOT_DETERMINED
                                  ? 'Loading...'
                                  : '${userData['gsid']}',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              'From  ',
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              dataStatus == DataStatus.NOT_DETERMINED
                                  ? 'Loading...'
                                  : '${userData['mother_planet']}',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Text(
                              'DOB  ',
                              style: TextStyle(color: Colors.white),
                            ),
                            Text(
                              dataStatus == DataStatus.NOT_DETERMINED
                                  ? 'Loading...'
                                  : '${userData['dateOfBirth']}',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
                ListTile(
                  title: RaisedButton(
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: Row(
                        children: <Widget>[
                          Icon(MdiIcons.home, size: 15),
                          SizedBox(
                            width: 15,
                          ),
                          Text('Home'),
                        ],
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext) => HomePage(
                                    email: widget.email,
                                    auth: widget.auth,
                                    userId: widget.email,
                                  )));
                    },
                  ),
                ),
                ListTile(
                  title: RaisedButton(
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: Row(
                        children: <Widget>[
                          Icon(MdiIcons.accountCardDetailsOutline, size: 15),
                          SizedBox(
                            width: 15,
                          ),
                          Text('My Martian Account'),
                        ],
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext) => Profile(
                                    email: widget.email,
                                    auth: widget.auth,
                                  )));
                    },
                  ),
                ),
                ListTile(
                  title: RaisedButton(
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: Row(
                        children: <Widget>[
                          Icon(MdiIcons.bank, size: 15),
                          SizedBox(
                            width: 15,
                          ),
                          Text('Bank'),
                        ],
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext) => Bank(
                                    email: widget.email,
                                    auth: widget.auth,
                                  )));
                    },
                  ),
                ),
                ListTile(
                  title: RaisedButton(
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.chat_bubble_outline, size: 15),
                          SizedBox(
                            width: 15,
                          ),
                          Text('Comms'),
                        ],
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext) => Comms(
                                    email: widget.email,
                                    auth: widget.auth,
                                  )));
                    },
                  ),
                ),
                ListTile(
                  title: RaisedButton(
                    color: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Container(
                      padding: EdgeInsets.fromLTRB(20, 10, 20, 10),
                      child: Row(
                        children: <Widget>[
                          Icon(
                            MdiIcons.logout,
                            size: 15,
                          ),
                          SizedBox(
                            width: 15,
                          ),
                          Text('Logout'),
                        ],
                      ),
                    ),
                    onPressed: () {
                      _signOut();
                    },
                  ),
                )
              ],
            ),
    );
  }

  void _signOut() async {
    try {
      await widget.auth.signOut();
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext) => CheckAuthentication(
                    auth: widget.auth,
                    userId: widget.email,
                  )));
    } catch (e) {
      print(e);
    }
  }
}

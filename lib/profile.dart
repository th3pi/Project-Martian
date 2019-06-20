import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'models/user_data.dart';
import 'services/authentication_check.dart';
import 'services/auth_service.dart';
import 'models/planet_data.dart';
import 'models/finance_data.dart';
import 'manage_passports.dart';

class Profile extends StatefulWidget {
  final BaseAuth auth;
  final String email;

  Profile({this.auth, this.email});

  @override
  State<StatefulWidget> createState() {
    return _ProfileState();
  }
}

enum DataStatus { NOT_DETERMINED, DETERMINED }

class _ProfileState extends State<Profile> with TickerProviderStateMixin {
  TabController tabController;
  DataStatus dataStatus = DataStatus.NOT_DETERMINED;
  User _user;
  File image, _cachedImage;
  StorageTaskSnapshot picDownloader;
  String picUrl, confirmedPicUrl;
  Map<String, dynamic> userData;
  List<Map<String, dynamic>> listOfIds = [];
  PlanetData planetData;
  int numOfIds, maxAccessLevel, numOfTransactions;
  bool criminalRecord = false;
  List<String> nameOfPlanets = [];
  List<Map<String, dynamic>> _sortedTransactions = [];
  Finance finance;
  double balance = 0, maxBalance = 0;
  bool debt = false, financialStability = true;

  @override
  void initState() {
    super.initState();
    tabController = TabController(length: 2, vsync: this);
    _user = User(email: widget.email);
    planetData = PlanetData(email: widget.email);
    finance = Finance(email: widget.email);
    _user.getAllData().then((value) {
      setState(() {
        dataStatus =
            value == null ? DataStatus.NOT_DETERMINED : DataStatus.DETERMINED;
        if (value != null) {
          userData = value;
        }
        Firestore.instance
            .collection('users')
            .document(widget.email)
            .collection('planetary_ids')
            .snapshots()
            .listen((snapshot) {
          dataStatus = snapshot == null
              ? DataStatus.NOT_DETERMINED
              : DataStatus.DETERMINED;
          if (snapshot != null) {
            snapshot.documents.forEach((doc) {
              listOfIds.add(doc.data);
            });
            _getPlanetaryData();
            Firestore.instance
                .collection('users')
                .document(widget.email)
                .collection('transactions')
                .orderBy('dateTimeOfTransaction', descending: true)
                .snapshots()
                .listen((onData) {
              dataStatus = onData == null
                  ? DataStatus.NOT_DETERMINED
                  : DataStatus.DETERMINED;
              if (onData != null) {
                onData.documents.forEach((f) {
                  if (this.mounted) {
                    setState(() {
                      _sortedTransactions.add(f.data);
                    });
                  }
                });
                _getFinancialData();
              }
            });
          }
        });
      });
    });
    downloadFile();
  }

  void _getPlanetaryData() async {
    int accessLevel = 0;
    numOfIds = listOfIds.length;
    for (int i = 0; i < listOfIds.length; i++) {
      nameOfPlanets.add(listOfIds[i]['planetName']);
      if (listOfIds[i]['criminalRecord'] == 'Yes') criminalRecord = true;
      if (int.parse(listOfIds[i]['accessLevel']) > accessLevel)
        accessLevel = int.parse(listOfIds[i]['accessLevel']);

      maxAccessLevel = accessLevel;
    }
  }

  void _getFinancialData() {
    balance = _sortedTransactions[0]['balance'];
    numOfTransactions = _sortedTransactions.length;
    print(balance);
    if (balance > 0) {
      debt = true;
    }
    if (!debt) {
      financialStability = false;
    }
    print(financialStability);
    for (int i = 0; i < _sortedTransactions.length; i++) {
      if (_sortedTransactions[i]['balance'] > maxBalance)
        maxBalance = _sortedTransactions[i]['balance'];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Martian Account',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(controller: tabController, tabs: <Widget>[
          Tab(
            icon: Icon(Icons.person),
          ),
          Tab(
            icon: Icon(Icons.card_membership),
          )
        ]),
      ),
      body: dataStatus == DataStatus.NOT_DETERMINED
          ? SpinKitDualRing(
              color: Colors.deepOrangeAccent,
            )
          : TabBarView(controller: tabController,
              children: <Widget>[_showBody(), PassportManager(listOfIds: listOfIds, email: widget.email, auth: widget.auth)],
            ),
    );
  }

  Widget _showBody() {
    return ListView(
      padding: EdgeInsets.only(top: 35),
      children: <Widget>[
        _profilePicture(),
        _fullName(),
        _globalId(),
        _header('Personal Information'),
        _userDetails(),
        _header('Planetary Information'),
        _planetDetails(),
        _header('Financial Information'),
        _financialDetails(),
      ],
    );
  }

  Future<void> getImageAndUpload(ImageSource source) async {
    var tempImage = await ImagePicker.pickImage(source: source);
    setState(() {
      image = tempImage;
    });
    StorageReference ref = FirebaseStorage.instance
        .ref()
        .child('${widget.email}_profile_picture.jpg');
    StorageUploadTask task = ref.putFile(image);
    await addProfilePhoto(task);
  }

  Future<void> addProfilePhoto(StorageUploadTask task) async {
    picDownloader = await task.onComplete;
    picUrl = await picDownloader.ref.getDownloadURL();
    await _user.addField('profilePic', picUrl);
  }

  Future<Null> downloadFile() async {
    final String filePath = '${widget.email}_profile_picture.jpg';
    final Directory tempDir = Directory.systemTemp;
    final File file = File('${tempDir.path}/$filePath');
    print(file);
    final StorageReference ref = FirebaseStorage.instance.ref().child(filePath);
    final StorageFileDownloadTask downloadTask = ref.writeToFile(file);

    final int byteNumber = (await downloadTask.future).totalByteCount;
    print(byteNumber);
    setState(() {
      _cachedImage = file;
      print(_cachedImage.path);
    });
  }

  void _profilePicOption() {
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
                              'Profile Picture',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ))),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                      width: 250,
                      child: RaisedButton(
                        color: Colors.white,
                        padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Icon(
                              Icons.camera_alt,
                              color: Colors.deepOrange,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Text(
                              'Take Picture',
                              style: TextStyle(
                                  color: Colors.deepOrange, fontSize: 20),
                            ),
                          ],
                        ),
                        elevation: 20,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        onPressed: () async {
                          Navigator.pop(context);
                          await getImageAndUpload(ImageSource.camera);
                        },
                      )),
                  SizedBox(
                    height: 10,
                  ),
                  Container(
                      width: 250,
                      child: RaisedButton(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'Choose from Gallery',
                              style: TextStyle(color: Colors.deepOrange),
                            ),
                          ],
                        ),
                        elevation: 20,
                        color: Colors.white,
                        padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                        onPressed: () async {
                          Navigator.pop(context);
                          await getImageAndUpload(ImageSource.gallery);
                        },
                      )),
                  SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget _managePassportButton() {
    return FlatButton(
        child: Text(
          'Manage Passports',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        onPressed: () {});
  }

  Widget _profilePicture() {
    return Center(
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.white, width: 10),
            boxShadow: [
              BoxShadow(
                  color: Colors.black12,
                  offset: Offset(2, 0),
                  blurRadius: 25,
                  spreadRadius: 1)
            ]),
        height: 200,
        width: 200,
        child: InkWell(
          onTap: () => _profilePicOption(),
          child: _cachedImage == null
              ? Image.asset('assets/mars_profile.jpg')
              : Image.asset(
                  _cachedImage.path,
                  fit: BoxFit.cover,
                ),
        ),
      ),
    );
  }

  Widget _fullName() {
    return Center(
      child: Container(
        padding: EdgeInsets.only(top: 15),
        child: Text(
          '${userData['firstName']} ${userData['lastName']}',
          style: TextStyle(
              color: Colors.deepOrange,
              fontWeight: FontWeight.bold,
              fontSize: 50),
        ),
      ),
    );
  }

  Widget _globalId() {
    return Center(
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Global Security ID:  ',
              style: TextStyle(color: Colors.deepOrange, fontSize: 15),
            ),
            Text(
              '${userData['gsid']}',
              style: TextStyle(
                  color: Colors.deepOrange,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
            SizedBox(
              width: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget _header(String header) {
    return Container(
      padding: EdgeInsets.fromLTRB(0, 20, 0, 5),
      child: Center(
          child: Text(
        header,
        style: TextStyle(
            color: Colors.black26, fontSize: 25, fontWeight: FontWeight.bold),
      )),
    );
  }

  Widget _financialDetails() {
    return Container(
      padding: EdgeInsets.fromLTRB(7, 0, 7, 0),
      child: Card(
        elevation: 15,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 15,
              ),
              Row(
                children: <Widget>[
                  Text('Current Balance: '),
                  Text(
                    '$balance',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.center,
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
                children: <Widget>[
                  Text('Max Balance: '),
                  Text(
                    '$maxBalance',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.center,
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
                children: <Widget>[
                  Text('Debt Incurred: '),
                  debt
                      ? Text(
                          'No',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        )
                      : Text(
                          'Yes',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        )
                ],
                mainAxisAlignment: MainAxisAlignment.center,
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
                children: <Widget>[
                  Text('Financial Stability: '),
                  financialStability
                      ? Text(
                          'Stable',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        )
                      : Text(
                          'Unstable',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        )
                ],
                mainAxisAlignment: MainAxisAlignment.center,
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
                children: <Widget>[
                  Text('Number of Transactions: '),
                  Text(
                    '$numOfTransactions',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
              SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _planetDetails() {
    return Container(
      padding: EdgeInsets.fromLTRB(7, 0, 7, 0),
      child: Card(
        elevation: 15,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 15,
              ),
              Row(
                children: <Widget>[
                  Text('Number of Passports: '),
                  Text(
                    '$numOfIds',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.center,
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
                children: <Widget>[
                  Text('Maximum Access Level: '),
                  Text(
                    '$maxAccessLevel',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  )
                ],
                mainAxisAlignment: MainAxisAlignment.center,
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
                children: <Widget>[
                  Text('Criminal Record: '),
                  criminalRecord
                      ? Text(
                          'Yes',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                        )
                      : Text(
                          'None',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                        )
                ],
                mainAxisAlignment: MainAxisAlignment.center,
              ),
              SizedBox(
                height: 15,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _userDetails() {
    return Container(
      padding: EdgeInsets.fromLTRB(7, 0, 7, 0),
      child: Card(
        elevation: 15,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                    '${userData['firstName']} ${userData['lastName']}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                    '${userData['dateOfBirth']}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                    '${userData['gender']}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text('Species: '),
                  Text(
                    '${userData['species']}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                  userData['martian'] == false
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
                    '${userData['mother_planet']}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                    '${userData['reason']}',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
      ),
    );
  }
}

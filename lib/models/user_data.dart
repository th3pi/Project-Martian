import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  String key;
  String userId,
      firstName,
      lastName,
      mother_planet,
      dateOfBirth,
      species,
      email,
      reason,
      gender;
  num gsid;
  bool martian;
  Map<String, dynamic> userData;

  User(
      {this.key,
      this.firstName,
      this.lastName,
      this.mother_planet,
      this.gsid,
      this.userId,
      this.species,
      this.dateOfBirth,
      this.gender,
      this.email,
      this.martian,
      this.reason});

  Future<Map<String, dynamic>> getAllData() async {
    await Firestore.instance
        .collection('users')
        .document(userId)
        .get()
        .then((value) {
      userData = value.data;
    });
    return userData;
  }

  Future<void> saveInfo() async {
    await Firestore.instance.collection('users').document(userId).setData({
      'userId': userId,
      'firstName': firstName,
      'lastName': lastName,
      'mother_planet': mother_planet,
      'gsid': gsid,
      'species': species,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      'email': email,
      'reason': reason,
      'martian': martian
    });
  }
}

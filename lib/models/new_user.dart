import 'package:cloud_firestore/cloud_firestore.dart';

import 'planet_data.dart';

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
      this.martian, this.reason}) {
    _saveInfo();
  }

  void _saveInfo() {
    Firestore.instance.runTransaction((Transaction transaction) async {
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
    });
  }
}

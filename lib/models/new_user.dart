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
    PlanetData(planetName: 'Mars', userId: userId, planetLastName: lastName, planetFirstName: firstName, idType: 'Visitor', planetaryId: gsid.toString(), flyingLicense: 'Yes', dateOfExpiration: '04/05/3010', dateIssued: '05/02/2900', criminalRecord: 'No', accessLevel: '1');
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

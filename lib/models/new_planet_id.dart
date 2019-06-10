import 'package:cloud_firestore/cloud_firestore.dart';

class AddPlanetData {
  String userId,
      planetFirstName,
      planetLastName,
      planetaryId,
      planetName,
      idType,
      dateOfExpiration,
      dateIssued,
      criminalRecord,
      accessLevel,
      flyingLicense;

  AddPlanetData(
      {this.userId,
      this.planetFirstName,
      this.planetLastName,
      this.planetaryId,
      this.planetName,
      this.idType,
      this.dateOfExpiration,
      this.dateIssued,
      this.criminalRecord,
      this.accessLevel,
      this.flyingLicense}) {
    _saveInfo();
  }

  void _saveInfo() {
    Firestore.instance.runTransaction((Transaction transaction) async {
      await Firestore.instance
          .collection('users')
          .document(userId)
          .collection('planetary_ids')
          .document(planetName)
          .setData({
        'userId': userId,
        'planetFirstName': planetFirstName,
        'planetLastName': planetLastName,
        'planetaryId': planetaryId,
        'planetName': planetName,
        'idType': idType,
        'dateOfExpiration': dateOfExpiration,
        'dateIssued': dateIssued,
        'criminalRecord': criminalRecord,
        'accessLevel': accessLevel,
        'flyingLicense': flyingLicense
      });
    });
  }

  void deleteId(String planetName) {
    Firestore.instance.runTransaction((Transaction tx) async {
      await Firestore.instance.collection('users').document(userId).collection('planetary_ids').document(planetName).delete();
    });
  }


}

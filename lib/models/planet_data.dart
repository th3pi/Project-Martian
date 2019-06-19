import 'package:cloud_firestore/cloud_firestore.dart';

class PlanetData {
  String email,
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
  List<Map<String, dynamic>> listOfIds = [];

  PlanetData(
      {this.email,
      this.planetFirstName,
      this.planetLastName,
      this.planetaryId,
      this.planetName,
      this.idType,
      this.dateOfExpiration,
      this.dateIssued,
      this.criminalRecord,
      this.accessLevel,
      this.flyingLicense});

  void saveInfo() {
    Firestore.instance.runTransaction((Transaction transaction) async {
      await Firestore.instance
          .collection('users')
          .document(email)
          .collection('planetary_ids')
          .document(planetName)
          .setData({
        'userId': email,
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
      await Firestore.instance
          .collection('users')
          .document(email)
          .collection('planetary_ids')
          .document(planetName)
          .delete();
    });
  }

  void getData() {
    Firestore.instance.runTransaction((Transaction tx) async {
      await Firestore.instance
          .collection('users')
          .document(email)
          .collection('planetary_ids')
          .document(planetName)
          .get()
          .then((value) {
        planetName = value.data['planetName'];
        planetFirstName = value.data['planetFirstName'];
        planetLastName = value.data['planetLastName'];
        planetaryId = value.data['planetaryId'];
        flyingLicense = value.data['flyingLicense'];
        dateOfExpiration = value.data['dateOfExpiration'];
        dateIssued = value.data['dateIssued'];
        criminalRecord = value.data['criminalRecord'];
        accessLevel = value.data['accessLevel'];
        flyingLicense = value.data['flyingLicense'];
      });
    });
  }

}

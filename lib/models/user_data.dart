import 'dart:io';
import 'package:device_info/device_info.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

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
      gender,
      profilePic;
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
        .document(email)
        .get()
        .then((value) {
      userData = value.data;
    });
    return userData;
  }

  Future<void> saveInfo() async {
    await Firestore.instance.collection('users').document(email).setData({
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
      'martian': martian,
    });
  }

  Future<void> addField(String fieldName, String data) async {
    await Firestore.instance
        .collection('users')
        .document(email)
        .updateData({fieldName: data});
  }

  Future<String> getField(String fieldName) async {
    await Firestore.instance
        .collection('users')
        .document(email)
        .get()
        .then((value) {
      profilePic = value.data[fieldName];
    });
    return profilePic;
  }
}

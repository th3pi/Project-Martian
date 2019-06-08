import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserData {
  String userId;
  Map<String, dynamic> allData;
  DocumentReference document;

  UserData(this.userId);

  Map<String, dynamic> getAllData() {
    _setAllData();
    return allData;
  }

  void _setAllData() {
    Firestore.instance.collection('users').document(userId).get().then((value) {
      if (value != null) {
        allData = {
          'firstName': value.data['firstName'],
          'lastName': value.data['lastName'],
          'email': value.data['email'],
          'dateOfBirth': value.data['dateOfBirth'],
          'gender': value.data['gender'],
          'gsid': value.data['gsid'],
          'martian': value.data['martian'],
          'mother_planet': value.data['mother_planet'],
          'reason': value.data['reason'],
          'species': value.data['species'],
          'userId': value.data['userId'],
        };
      }
    });
  }

//  String getFirstName() {
//    document = Firestore.instance.collection('users').document(userId);
//    document.get().then((data){
//      if(data.exists){
//        firstName = data.data['firstName'];
//        return firstName;
//      }else{
//        return firstName = '404';
//      }
//    });
//  }
}

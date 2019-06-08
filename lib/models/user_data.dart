import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserData {
  String key;
  String userId,
      firstName ='',
      lastName,
      mother_planet,
      dateOfBirth,
      species,
      gender;
  num gsid;
  DocumentReference document;

  UserData(
      {this.key,
      this.firstName,
      this.lastName,
      this.mother_planet,
      this.gsid,
      this.userId,
      this.species,
      this.dateOfBirth,
      this.gender});

  String getAppBarFirstName() {

    DocumentReference reference = Firestore.instance.collection('users').document(userId);
    reference.get().then((data) {
      if(data.exists) {
        firstName = data.data['firstName'];
        return firstName;
        print(firstName);
      }else{
        firstName = '';
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

import 'package:cloud_firestore/cloud_firestore.dart';

class Contacts {

  final String userEmail;

  Contacts({this.userEmail});

  Future<void> addContact(String email) async {
    await Firestore.instance.collection('users').document(userEmail).collection('contacts').document(email).setData({
      'status' : 'pending',
      'contactEmail' : email,
    });

    await Firestore.instance.collection('users').document(email).collection('contacts').document(userEmail).setData({
      'status' : 'pending',
      'contactEmail' : userEmail,
    });
  }

  Future<void> removeContact(String email) {

  }

}
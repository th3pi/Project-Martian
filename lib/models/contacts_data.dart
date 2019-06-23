import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_data.dart';

class Contacts {

  final String userEmail;

  Contacts({this.userEmail});

  Future<void> addContact(String email) async {


    User receiver = User(email: email);
    Map<String, dynamic> receiverData = await receiver.getAllData();

    //Request Sender
    await Firestore.instance.collection('users').document(userEmail).collection('contacts').document(email).setData({
      'status' : 'pending',
      'contactEmail' : email,
      'requestedBy' : userEmail,
      'requestedTo' : email,
      'contactFirstName' : receiverData['firstName'],
      'contactLastName' : receiverData['lastName'],
    });

    User sender = User(email: userEmail);
    Map<String, dynamic> senderData = await sender.getAllData();

    //Request Receiver
    await Firestore.instance.collection('users').document(email).collection('contacts').document(userEmail).setData({
      'status' : 'pending',
      'contactEmail' : userEmail,
      'requestedBy' : userEmail,
      'requestedTo' : email,
      'contactFirstName' : senderData['firstName'],
      'contactLastName' : senderData['lastName'],
    });
  }

  Future<void> removeContact(String email) {

  }

}
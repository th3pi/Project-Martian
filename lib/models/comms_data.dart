import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_data.dart';
import 'contacts_data.dart';
import '../services/auth_service.dart';
import 'package:uuid/uuid.dart';

class CommsData {
  final String email;
  final BaseAuth auth;

  CommsData({this.auth, this.email});

  Future<void> sendMessage(String to, String message) async {
    final messageId = Uuid().v4();

    Map<String, dynamic> senderData = await User(email: email).getAllData();
    Map<String, dynamic> receiverData = await User(email: to).getAllData();

    //Sender
    await Firestore.instance
        .collection('users')
        .document(email)
        .collection('contacts')
        .document(to)
        .collection('messages')
        .document(messageId)
        .setData({
      'type': 'sent',
      'senderName': '${senderData['firstName']}',
      'senderEmail': '$email',
      'date':
          '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}',
      'time': '${DateTime.now().hour}:${DateTime.now().minute}',
      'dateTime': '${DateTime.now()}',
      'receiverName': '${receiverData['firstName']}',
      'message': '$message',
      'receiverEmail': '$to'
    });

    //Receiver
    await Firestore.instance
        .collection('users')
        .document(to)
        .collection('contacts')
        .document(email)
        .collection('messages')
        .document(messageId)
        .setData({
      'type': 'received',
      'senderName': '${senderData['firstName']}',
      'senderEmail': '$email',
      'date':
          '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}',
      'time': '${DateTime.now().hour}:${DateTime.now().minute}',
      'dateTime': '${DateTime.now()}',
      'receiverName': '${receiverData['firstName']}',
      'message': '$message',
      'receiverEmail': '$to',
    });
  }

  Future<QuerySnapshot> getAllMessages(String to) {
    final snapshot = Firestore.instance
        .collection('users')
        .document(email)
        .collection('contacts')
        .document(to)
        .collection('messages')
        .getDocuments();
    return snapshot;
  }
}

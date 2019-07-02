import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_data.dart';
import 'contacts_data.dart';
import '../services/auth_service.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

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
        .collection('communications')
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
      'formattedTime' : '${DateFormat.jm().format(DateTime.now())}',
      'formattedDateTime' : '${DateFormat.Md().add_jm().format(DateTime.now())}',
      'receiverName': '${receiverData['firstName']}',
      'message': '$message',
      'receiverEmail': '$to',
      'messageId': '$messageId'
    });

    //Receiver
    await Firestore.instance
        .collection('users')
        .document(to)
        .collection('communications')
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
      'formattedTime' : '${DateFormat.jm().format(DateTime.now())}',
      'formattedDateTime' : '${DateFormat.Md().add_jm().format(DateTime.now())}',
      'receiverName': '${receiverData['firstName']}',
      'message': '$message',
      'receiverEmail': '$to',
      'messageId': '$messageId'
    });

    //Document update
    await Firestore.instance
        .collection('users')
        .document(email)
        .collection('communications')
        .document(to)
        .setData({
      'dateTimeOfLastMessage':
      '${DateTime.now()}',
      'formattedDateTime' : '${DateFormat.yMd().add_jms().format(DateTime.now())}',
      'lastMessage': '$message',
      'lastMessageType': 'sent',
      'profilePic': receiverData['profilePic'],
      'name': '${receiverData['firstName']} ${receiverData['lastName']}',
      'senderEmail': '${senderData['email']}',
      'receiverEmail': '${receiverData['email']}'
    });
    await Firestore.instance
        .collection('users')
        .document(to)
        .collection('communications')
        .document(email)
        .setData({
      'dateTimeOfLastMessage': '${DateTime.now()}',
      'formattedDateTime' : '${DateFormat.yMd().add_jms().format(DateTime.now())}',
      'lastMessage': '$message',
      'lastMessageType': 'received',
      'profilePic': senderData['profilePic'],
      'name': '${senderData['firstName']} ${senderData['lastName']}',
      'senderEmail': '${senderData['email']}',
      'receiverEmail': '${receiverData['email']}'
    });
  }

  Future<QuerySnapshot> getAllContactMessages(String to) {
    final snapshot = Firestore.instance
        .collection('users')
        .document(email)
        .collection('communications')
        .document(to)
        .collection('messages')
        .getDocuments();
    return snapshot;
  }

  Future<QuerySnapshot> getAllMessages() {
    final snapshot = Firestore.instance
        .collection('users')
        .document(email)
        .collection('communications')
        .getDocuments();
    return snapshot;
  }
}

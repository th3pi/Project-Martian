import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_data.dart';

class Contacts {
  final String userEmail;

  Contacts({this.userEmail});

  Future<void> addContact(String email) async {
    User receiver = User(email: email);
    Map<String, dynamic> receiverData = await receiver.getAllData();

    //Request Sender
    await Firestore.instance
        .collection('users')
        .document(userEmail)
        .collection('contacts')
        .document(email)
        .setData({
      'status': 'pending',
      'contactEmail': email,
      'requestedBy': userEmail,
      'requestedTo': email,
      'contactImage': receiverData['profilePic'],
      'contactFirstName': receiverData['firstName'],
      'contactLastName': receiverData['lastName'],
    });

    User sender = User(email: userEmail);
    Map<String, dynamic> senderData = await sender.getAllData();

    //Request Receiver
    await Firestore.instance
        .collection('users')
        .document(email)
        .collection('contacts')
        .document(userEmail)
        .setData({
      'status': 'pending',
      'contactEmail': userEmail,
      'requestedBy': userEmail,
      'requestedTo': email,
      'contactImage': senderData['profilePic'],
      'contactFirstName': senderData['firstName'],
      'contactLastName': senderData['lastName'],
    });
  }

  Future<QuerySnapshot> getPendingContacts() async {
    List<Map<String, dynamic>> pendingContacts;
//    Firestore.instance
//        .collection('users')
//        .document(userEmail)
//        .collection('contacts')
//        .where('status', isEqualTo: 'pending')
//        .snapshots()
//        .listen((snapshot) {
//      snapshot.documents.forEach((f) {
////        print(f.data);
//        pendingContacts.add(f.data);
//      });
//    });
    final QuerySnapshot querySnapshot = await Firestore.instance
        .collection('users')
        .document(userEmail)
        .collection('contacts')
        .where('status', isEqualTo: 'pending')
        .getDocuments();
    return querySnapshot;
  }

  Future<void> updateStatus(String email, String status) async {
    await Firestore.instance
        .collection('users')
        .document(userEmail)
        .collection('contacts')
        .document(email)
        .updateData({'status': status});
    await Firestore.instance
        .collection('users')
        .document(email)
        .collection('contacts')
        .document(userEmail)
        .updateData({'status': status});
  }

  Future<void> removeContact(String email) {}
}

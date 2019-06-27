import 'package:cloud_firestore/cloud_firestore.dart';
import 'user_data.dart';

class Contacts {
  final String userEmail;

  Contacts({this.userEmail});

  Future<QuerySnapshot> getAllUsers(String fullName) async {
    final QuerySnapshot querySnapshot = await Firestore.instance
        .collection('users')
        .where('fullName', isEqualTo: fullName)
        .getDocuments();
    return querySnapshot;
  }

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
      'mother_planet': receiverData['mother_planet'],
      'species': receiverData['species'],
      'reason': receiverData['reason'],
      'martian': receiverData['martian'],
      'gender': receiverData['gender'],
      'dateOfBirth': receiverData['dateOfBirth'],
      'status': 'pending',
      'contactEmail': email,
      'requestedBy': userEmail,
      'requestedTo': email,
      'profilePic': receiverData['profilePic'],
      'firstName': receiverData['firstName'],
      'lastName': receiverData['lastName'],
      'fullName': '${receiverData['firstName']} ${receiverData['lastName']}'
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
      'mother_planet': senderData['mother_planet'],
      'species': senderData['species'],
      'reason': senderData['reason'],
      'martian': senderData['martian'],
      'gender': senderData['gender'],
      'dateOfBirth': senderData['dateOfBirth'],
      'status': 'pending',
      'contactEmail': userEmail,
      'requestedBy': userEmail,
      'requestedTo': email,
      'profilePic': senderData['profilePic'],
      'firstName': senderData['firstName'],
      'lastName': senderData['lastName'],
      'fullName': '${senderData['firstName']} ${senderData['lastName']}'
    });
  }

  Future<QuerySnapshot> getPendingContacts() async {
    final QuerySnapshot querySnapshot = await Firestore.instance
        .collection('users')
        .document(userEmail)
        .collection('contacts')
        .where('status', isEqualTo: 'pending')
        .getDocuments();
    return querySnapshot;
  }

  Future<QuerySnapshot> getAllContacts() async {
    final QuerySnapshot querySnapshot = await Firestore.instance
        .collection('users')
        .document(userEmail)
        .collection('contacts')
        .where('status', isEqualTo: 'accepted')
        .getDocuments();
    return querySnapshot;
  }

  Future<Stream<QuerySnapshot>> getNewContacts() async {
    final Stream<QuerySnapshot> querySnapshot = Firestore.instance
        .collection('users')
        .document(userEmail)
        .collection('contacts')
        .where('status', isEqualTo: 'accepted')
        .snapshots();
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

  Future<void> removeContact(String email) async {
    await Firestore.instance
        .collection('users')
        .document(userEmail)
        .collection('contacts')
        .document(email)
        .delete();
    await Firestore.instance
        .collection('users')
        .document(email)
        .collection('contacts')
        .document(userEmail)
        .delete();
  }
}

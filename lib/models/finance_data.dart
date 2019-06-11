import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class Finance {
  String userId, transactionType;
  double balance;
  var transactionId = Uuid();

  Finance({this.userId, this.balance});

  void sendMoney(double amount) {
    Firestore.instance.runTransaction((Transaction transaction) async {
      await Firestore.instance
          .collection('users')
          .document(userId)
          .collection('transactions')
          .document(transactionId.v4())
          .setData({
        'userId': userId,
        'transactionType': 'send',
        'balance': balance - amount
      });
    });
  }

  Future<void> setBalance(double amount) async {
    await Firestore.instance
        .collection('users')
        .document(userId)
        .collection('finance')
        .document('balance')
        .setData({'balance': amount});
  }

  Future<double> getBalance() async {
    await Firestore.instance
        .collection('users')
        .document(userId)
        .collection('finance')
        .document('balance')
        .get()
        .then((value) {
      balance = value.data['balance'];
    });
    return balance;
  }
}

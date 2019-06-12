import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'dart:math';
import 'package:random_string/random_string.dart';

class Finance {
  String userId, name, transactionType;
  double balance;
  var transactionId = Uuid();

  Finance({this.userId, this.balance, this.name});

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

  Future<void> createNewFinanceAccount() async {
    await Firestore.instance
        .collection('users')
        .document(userId)
        .collection('finance')
        .document('balance')
        .setData({'balance': 0, 'accNumber': randomString(12), 'name' : name, 'dateOfExpiration' : '03/19/3010'});
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

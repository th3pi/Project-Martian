import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:random_string/random_string.dart';

class Finance {
  String email, name, transactionType;
  double balance, receiversBalance;
  Map<String, dynamic> financeData;
  List<Map<String, dynamic>> sortedTransactions = [];
  CollectionReference reference;
  bool userExists;
  var transactionId = Uuid();

  Finance({this.email, this.balance, this.name});

  Future<void> sendMoney(double amount, String to) async {
    String txId = Uuid().v4();
    await Firestore.instance
        .collection('users')
        .document(email)
        .collection('finance')
        .document('accountDetails')
        .get()
        .then((data) {
      balance = data.data['balance'];
    });
    await Firestore.instance
        .collection('users')
        .document(email)
        .collection('transactions')
        .document(txId)
        .setData({
      'transactionId': txId,
      'amount' : amount,
      'receiver' : to,
      'userId': email,
      'transactionType': 'Sent',
      'dateTimeOfTransaction': '${DateTime.now()}',
      'dateOfTransaction':
          '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year + 800}',
      'timeOfTransaction':
          '${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}',
      'balance': num.parse((balance - amount).toStringAsFixed(2))
    });
    setBalance(num.parse((balance - amount).toStringAsFixed(2)), email);
    await Firestore.instance
        .collection('users')
        .document(to)
        .collection('finance')
        .document('accountDetails')
        .get()
        .then((data) {
      receiversBalance = data.data['balance'];
    });
    await Firestore.instance
        .collection('users')
        .document(to)
        .collection('transactions')
        .document(txId)
        .setData({
      'transactionId': txId,
      'amount' : amount,
      'sender' : email,
      'userId': to,
      'transactionType': 'Received',
      'dateTimeOfTransaction': '${DateTime.now()}',
      'dateOfTransaction':
          '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year + 800}',
      'timeOfTransaction':
          '${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}',
      'balance': num.parse((receiversBalance + amount).toStringAsFixed(2))
    });
    setBalance(num.parse((receiversBalance + amount).toStringAsFixed(2)), to);
  }

  Future<void> depositMoney(double amount) async {
    String txId = Uuid().v4();
    getBalance(email).then((value) {
      balance = value;
    });
    await Firestore.instance
        .collection('users')
        .document(email)
        .collection('transactions')
        .document(txId)
        .setData({
      'transactionId': txId,
      'amount' : amount,
      'userId': email,
      'transactionType': 'deposit',
      'dateTimeOfTransaction': '${DateTime.now()}',
      'dateOfTransaction':
          '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year + 800}',
      'timeOfTransaction':
          '${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}',
      'balance': num.parse((balance + amount).toStringAsFixed(2))
    });
    setBalance(num.parse((balance + amount).toStringAsFixed(2)), null);
  }

  Future<Map<String, dynamic>> getData() async {
    await Firestore.instance
        .collection('users')
        .document(email)
        .collection('finance')
        .document('accountDetails')
        .get()
        .then((value) {
      financeData = value.data;
    });
    return financeData;
  }

  Future<void> createNewFinanceAccount() async {
    await Firestore.instance
        .collection('users')
        .document(email)
        .collection('finance')
        .document('accountDetails')
        .setData({
      'balance': 00.86,
      'accNumber': randomNumeric(12),
      'name': name,
      'dateOfExpiration': '03/19/3010'
    });
  }

  Future<void> setBalance(double amount, String email) async {
    await Firestore.instance
        .collection('users')
        .document(email == null ? this.email : email)
        .collection('finance')
        .document('accountDetails')
        .updateData({'balance': amount});
  }

  Future<double> getBalance(String email) async {
    await Firestore.instance
        .collection('users')
        .document(email == null ? this.email : email)
        .collection('finance')
        .document('accountDetails')
        .get()
        .then((value) {
      balance = value.data['balance'];
    });
    return balance;
  }

  Future<CollectionReference> checkForBalanceChanges() async {
    reference = Firestore.instance
        .collection('users')
        .document(email)
        .collection('finance');
    return reference;
  }

  Future<List<Map<String, dynamic>>> getTransactionsSorted() async {
    Firestore.instance
        .collection('users')
        .document(email)
        .collection('transactions')
        .orderBy('dateTimeOfTransaction', descending: true)
        .snapshots()
        .listen((onData) {
      onData.documents.forEach((f) {
        sortedTransactions.add(f.data);
      });
    });
    return sortedTransactions;
  }

  Future<bool> checkIfUserExists(String email) async {
    await Firestore.instance.collection('users').where('email', isEqualTo: email.toLowerCase()).limit(1).getDocuments().then((value){
      if(value.documents.length == 1){
        userExists = true;
      }else{
        userExists = false;
      }
    });
    return userExists;
  }
}

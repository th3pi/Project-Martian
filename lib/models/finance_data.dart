import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:random_string/random_string.dart';

class Finance {
  String userId, name, transactionType;
  double balance;
  Map<String, dynamic> financeData;
  List<Map<String, dynamic>> sortedTransactions = [];
  CollectionReference reference;
  var transactionId = Uuid();

  Finance({this.userId, this.balance, this.name});

  Future<void> sendMoney(double amount, double balance) async {
    await Firestore.instance
        .collection('users')
        .document(userId)
        .collection('transactions')
        .document(transactionId.v4())
        .setData({
      'userId': userId,
      'transactionType': 'send',
      'dateTimeOfTransaction' : '${DateTime.now()}',
      'dateOfTransaction' : '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year+800}',
      'timeOfTransaction' :'${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}',
      'balance': balance - amount
    });
  }

  Future<void> depositMoney(double amount, double balance) async {
    await Firestore.instance
        .collection('users')
        .document(userId)
        .collection('transactions')
        .document(transactionId.v4())
        .setData({
      'userId': userId,
      'transactionType': 'deposit',
      'dateTimeOfTransaction' : '${DateTime.now()}',
      'dateOfTransaction' : '${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year+800}',
      'timeOfTransaction' :'${DateTime.now().hour}:${DateTime.now().minute}:${DateTime.now().second}',
      'balance': balance + amount
    });
  }

  Future<Map<String, dynamic>> getData() async {
    await Firestore.instance
        .collection('users')
        .document(userId)
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
        .document(userId)
        .collection('finance')
        .document('accountDetails')
        .setData({
      'balance': 00.86,
      'accNumber': randomNumeric(12),
      'name': name,
      'dateOfExpiration': '03/19/3010'
    });
  }

  Future<void> setBalance(double amount) async {
    await Firestore.instance
        .collection('users')
        .document(userId)
        .collection('finance')
        .document('accountDetails')
        .updateData({'balance': amount});
  }

  Future<double> getBalance() async {
    await Firestore.instance
        .collection('users')
        .document(userId)
        .collection('finance')
        .document('accountDetails')
        .get()
        .then((value) {
      balance = value.data['balance'];
    });
    return balance;
  }
  
  Future<CollectionReference> checkForBalanceChanges() async {
    reference =
        Firestore.instance.collection('users').document(userId).collection(
            'finance');
    return reference;
  }
  
  Future<List<Map<String, dynamic>>> getTransactionsSorted() async {
    Firestore.instance.collection('users').document(userId).collection('transactions').orderBy('dateTimeOfTransaction', descending: false).snapshots().listen((onData){
      onData.documents.forEach((f){
        sortedTransactions.add(f.data);
      });
    });
    return sortedTransactions;
  }
}

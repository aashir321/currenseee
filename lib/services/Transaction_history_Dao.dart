import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:currensee/models/Transaction_history.dart';
class TransactionHistoryDao {
    final _databaseRef = FirebaseDatabase.instance.ref("transaction_history"); 


  Future saveTransactionHistory (TransactionHistory transactionHistory, String? uuid) async{
      if (uuid!=null) {
        await _databaseRef.child(uuid).push().set(transactionHistory.toJson());
      }
  }


  Query getTransactionHistoryQuery(String? uuid){
    if (!kIsWeb) {
      FirebaseDatabase.instance.setPersistenceEnabled(true);
    }
    return _databaseRef.child(uuid.toString());
  } 

  Future deleteTransactionHistory(String? uuid, String key) async{
      await _databaseRef.child(uuid.toString()).child(key).remove();
  }   
  
}
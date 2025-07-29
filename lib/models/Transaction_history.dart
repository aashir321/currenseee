class TransactionHistory{
 String fromCurrency;
 String toCurrency;
 double amount;
 double result;
 String date;
 TransactionHistory({required this.fromCurrency, required this.toCurrency, required this.amount, required this.result, required this.date}); 

  TransactionHistory.fromJson(Map<dynamic,dynamic> json):
    fromCurrency=json['fromCurrency'] as String,
    toCurrency=json['toCurrency'] as String,
    amount=json['amount'] as double,
    result=json['result'] as double,
    date=json['date'] as String;


  Map<dynamic,dynamic> toMap()=><String,dynamic>{
    'fromCurrency': fromCurrency,
    'toCurrency': toCurrency,
    'amount': amount,
    'result': result,
    'date': date
  };


 Map<String,dynamic> toJson()=><String,dynamic>{
    'fromCurrency': fromCurrency,
    'toCurrency': toCurrency,
    'amount': amount,
    'result': result,
    'date': date
  };

} 
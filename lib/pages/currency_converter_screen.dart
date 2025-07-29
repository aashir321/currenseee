import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:currensee/models/Transaction_history.dart';
import 'package:currensee/services/Transaction_history_Dao.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:intl/intl.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  _CurrencyConverterScreenState createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  String? uuid;
  TransactionHistoryDao transaction_history = TransactionHistoryDao();
  final ScrollController _scrollController = ScrollController();
  String? key;
  String apiKey = '6ogAWXOm84GyBdaVzp9ZoSG0sU4pvVdt';
  // apiKey = '6ogAWXOm84GyBdaVzp9ZoSG0sU4pvVdt'
  Map<String, String> currencies = {};
  String fromCurrency = 'USD';
  String toCurrency = 'EUR';
  double amount = 1.0;
  double result = 0.0;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    if (mounted) {
      fetchCurrencies();
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        uuid = user.uid;
      }

      final connectedRef = transaction_history.getTransactionHistoryQuery(uuid);
      connectedRef.keepSynced(true);
    }
  }

  Future<void> fetchCurrencies() async {
    if (!mounted) return;
    try {
      final response = await http.get(
        Uri.parse('https://api.apilayer.com/exchangerates_data/symbols'),
        headers: {'apikey': apiKey},
      );
      if (response.statusCode == 200 && mounted) {
        var data = json.decode(response.body);
        setState(() {
          currencies = Map<String, String>.from(data['symbols']);
        });
      } else {
        throw Exception('Failed to load currencies');
      }
    } catch (e) {
      print('Error fetching currencies: $e');
    }
  }

  Future<void> convertCurrency() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse(
            'https://api.apilayer.com/exchangerates_data/convert?from=$fromCurrency&to=$toCurrency&amount=$amount'),
        headers: {'apikey': apiKey},
      );
      if (response.statusCode == 200 && mounted) {
        var data = json.decode(response.body);
        setState(() {
          result = data['result'];
          isLoading = false;
        });
        addData();
      } else {
        throw Exception('Failed to convert currency');
      }
    } catch (e) {
      print('Error converting currency: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void addData() {
    final date = DateTime.now().toString();
    final transaction = TransactionHistory(
        fromCurrency: fromCurrency,
        toCurrency: toCurrency,
        amount: amount,
        result: result,
        date: date);
    transaction_history.saveTransactionHistory(transaction, uuid);
  }

  void _showCurrencyPicker(BuildContext context, bool isFromCurrency) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            List<MapEntry<String, String>> filteredCurrencies = currencies
                .entries
                .where((entry) =>
                    entry.key
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()) ||
                    entry.value
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()))
                .toList();

            return AlertDialog(
              title: Text(
                  isFromCurrency
                      ? 'Select From Currency'
                      : 'Select To Currency',
                  style: TextStyle(color: Color(0xFF1A1A2E))),
              content: Container(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      style: TextStyle(color: Color(0xFF1A1A2E)),
                      decoration: InputDecoration(
                        hintText: 'Search currency...',
                        hintStyle: TextStyle(color: Colors.grey),
                        prefixIcon:
                            Icon(Icons.search, color: Color(0xFF1A1A2E)),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Color(0xFF1A1A2E)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Color(0xFF1A1A2E)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: Color(0xFF1A1A2E), width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredCurrencies.length,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text(
                                '${filteredCurrencies[index].key} - ${filteredCurrencies[index].value}'),
                            onTap: () {
                              setState(() {
                                if (isFromCurrency) {
                                  fromCurrency = filteredCurrencies[index].key;
                                } else {
                                  toCurrency = filteredCurrencies[index].key;
                                }
                              });
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Currency Converter',
          style:
              TextStyle(color: Color(0xFF1A1A2E), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A2E)),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 3,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        'Convert Currencies',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => _showCurrencyPicker(context, true),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'From Currency',
                            labelStyle: TextStyle(color: Color(0xFF1A1A2E)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFF1A1A2E)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFF1A1A2E)),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(fromCurrency,
                                  style: TextStyle(color: Color(0xFF1A1A2E))),
                              Icon(Icons.arrow_drop_down,
                                  color: Color(0xFF1A1A2E)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => _showCurrencyPicker(context, false),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'To Currency',
                            labelStyle: TextStyle(color: Color(0xFF1A1A2E)),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFF1A1A2E)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(color: Color(0xFF1A1A2E)),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(toCurrency,
                                  style: TextStyle(color: Color(0xFF1A1A2E))),
                              Icon(Icons.arrow_drop_down,
                                  color: Color(0xFF1A1A2E)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      TextField(
                        style: TextStyle(color: Color(0xFF1A1A2E)),
                        decoration: InputDecoration(
                          labelText: 'Amount',
                          labelStyle: TextStyle(color: Color(0xFF1A1A2E)),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Color(0xFF1A1A2E)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Color(0xFF1A1A2E)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                BorderSide(color: Color(0xFF1A1A2E), width: 2),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          setState(() {
                            amount = double.tryParse(value) ?? 0.0;
                          });
                        },
                      ),
                      SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1A1A2E),
                          padding: EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () {
                          convertCurrency();
                        },
                        child: Text(
                          'Convert',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                      SizedBox(height: 20),
                      isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFF1A1A2E))))
                          : Container(
                              padding: EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Color(0xFF1A1A2E).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Result: ${result.toStringAsFixed(2)} $toCurrency',
                                style: TextStyle(
                                    fontSize: 24,
                                    color: Color(0xFF1A1A2E),
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.center,
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              flex: 2,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFF0F0F5),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Transaction History',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                    Expanded(
                      child: getTransactionList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getTransactionList() {
    return FirebaseAnimatedList(
      controller: _scrollController,
      query: transaction_history.getTransactionHistoryQuery(uuid),
      itemBuilder: (context, snapshot, animation, index) {
        final json = snapshot.value as Map<dynamic, dynamic>;
        final transactionHistory = TransactionHistory.fromJson(json);
        return Dismissible(
          key: UniqueKey(),
          onDismissed: (direction) {
            setState(() {
              transaction_history.deleteTransactionHistory(
                  uuid, snapshot.key.toString());
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text("Transaction deleted")));
            });
          },
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 20.0),
            child: Icon(Icons.delete, color: Colors.white),
          ),
          direction: DismissDirection.startToEnd,
          child: Card(
            elevation: 4.0,
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: ListTile(
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              leading: CircleAvatar(
                backgroundColor: Color(0xFF1A1A2E),
                child: Text(
                  transactionHistory.fromCurrency.substring(0, 2),
                  style: TextStyle(color: Colors.white),
                ),
              ),
              title: Text(
                '${transactionHistory.amount} ${transactionHistory.fromCurrency} → ${transactionHistory.result.toStringAsFixed(2)} ${transactionHistory.toCurrency}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                DateFormat('MMM d, y HH:mm')
                    .format(DateTime.parse(transactionHistory.date)),
                style: TextStyle(color: Colors.grey),
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: Color(0xFF1A1A2E)),
            ),
          ),
        );
      },
    );
  }
}

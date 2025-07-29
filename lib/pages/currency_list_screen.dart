import 'package:currensee/pages/currency_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CurrencyListScreen extends StatefulWidget {
  const CurrencyListScreen({super.key});

  @override
  _CurrencyListScreenState createState() => _CurrencyListScreenState();
}

class _CurrencyListScreenState extends State<CurrencyListScreen> {
  Map<String, String> currencies = {};
  Map<String, dynamic> rates = {};
  Map<String, double> changes = {};
  bool isLoading = true;
  String searchText = '';
  String apiKey = '6ogAWXOm84GyBdaVzp9ZoSG0sU4pvVdt';
  //  String apiKey = '6ogAWXOm84GyBdaVzp9ZoSG0sU4pvVdt'; // Remember to use your actual API key

  @override
  void initState() {
    super.initState();
    loadCurrencyData();
  }

  void loadCurrencyData() async {
    try {
      await fetchCurrencies();
      await fetchRates();
      await fetchHistoricalRates();
      if (mounted) {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> fetchCurrencies() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.apilayer.com/exchangerates_data/symbols'),
        headers: {'apikey': apiKey},
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() => currencies = Map<String, String>.from(data['symbols']));
      } else {
        print(
            'Error fetching currencies: ${response.statusCode} ${response.body}');
        throw Exception('Failed to load currencies');
      }
    } catch (e) {
      print('Exception during fetching currencies: $e');
      throw Exception('Failed to load currencies');
    }
  }

  Future<void> fetchRates() async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://api.apilayer.com/exchangerates_data/latest?base=USD'),
        headers: {'apikey': apiKey},
      );
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() => rates = data['rates']);
      } else {
        print('Error fetching rates: ${response.statusCode} ${response.body}');
        throw Exception('Failed to load exchange rates');
      }
    } catch (e) {
      print('Exception during fetching rates: $e');
      throw Exception('Failed to load exchange rates');
    }
  }

  Future<void> fetchHistoricalRates() async {
    try {
      // For example, fetch historical rates for the last 7 days
      List<Future<void>> fetchPromises = [];
      DateTime now = DateTime.now();
      for (int i = 1; i <= 7; i++) {
        DateTime date = now.subtract(Duration(days: i));
        String formattedDate =
            date.toIso8601String().split('T').first; // Format as YYYY-MM-DD
        final response = await http.get(
          Uri.parse(
              'https://api.apilayer.com/exchangerates_data/$formattedDate?base=USD'),
          headers: {'apikey': apiKey},
        );
        if (response.statusCode == 200) {
          var data = json.decode(response.body);
          // Store historical rates, e.g., in a Map<String, double>
          // You might want to adjust this based on your needs
          for (var entry in data['rates'].entries) {
            changes[entry.key] = (changes[entry.key] ?? 0) +
                (entry.value -
                    rates[entry.key]); // Update change calculation logic
          }
        } else {
          print(
              'Error fetching historical rates for $formattedDate: ${response.statusCode} ${response.body}');
          throw Exception('Failed to load historical rates');
        }
      }
    } catch (e) {
      print('Exception during fetching historical rates: $e');
      throw Exception('Failed to load historical rates');
    }
  }

  List<MapEntry<String, String>> get filteredCurrencies {
    return currencies.entries.where((entry) {
      return entry.key.toLowerCase().contains(searchText.toLowerCase()) ||
          entry.value.toLowerCase().contains(searchText.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'CurrenSee Exchange Rates',
          style: TextStyle(
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF1A1A2E)),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              style: const TextStyle(color: Color(0xFF1A1A2E)),
              decoration: InputDecoration(
                hintText: 'Search currencies...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: Icon(Icons.search, color: Color(0xFF1A1A2E)),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xFF1A1A2E)),
                ),
              ),
              onChanged: (value) => setState(() => searchText = value),
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF1A1A2E))))
                : ListView.builder(
                    itemCount: filteredCurrencies.length,
                    itemBuilder: (context, index) {
                      final currency = filteredCurrencies[index];
                      final rate = rates[currency.key];
                      final change =
                          changes[currency.key]?.toStringAsFixed(2) ?? 'N/A';

                      return Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 2,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Color(0xFF1A1A2E).withOpacity(0.1),
                            child: Text(
                              currency.key.substring(0, 2),
                              style: TextStyle(
                                  color: Color(0xFF1A1A2E),
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(
                            currency.value,
                            style: TextStyle(
                                color: Color(0xFF1A1A2E),
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(currency.key,
                              style: TextStyle(color: Colors.grey[600])),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                rate != null ? rate.toStringAsFixed(4) : 'N/A',
                                style: TextStyle(
                                    color: Color(0xFF1A1A2E),
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                change != 'N/A' ? '$change%' : change,
                                style: TextStyle(
                                  color: change.startsWith('-')
                                      ? Colors.red
                                      : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CurrencyDetailScreen(
                                  currencyName: currency.key,
                                  currencyChange:
                                      change, // Pass the change to the detail screen
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Clean up any controllers or listeners here, if needed.
    super.dispose();
  }
}

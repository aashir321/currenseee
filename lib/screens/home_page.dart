import 'package:currensee/widgets/drawer.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:currensee/pages/currency_list_screen.dart';
import 'package:currensee/pages/currency_converter_screen.dart';
import 'package:currensee/pages/currency_detail_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.displayName}) : super(key: key);
  final String displayName;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> topCurrencies = [];
  bool isLoading = true;
  // String apiKey =
  // '6ogAWXOm84GyBdaVzp9ZoSG0sU4pvVdt'; // Replace with your actual API key
  String apiKey = '6ogAWXOm84GyBdaVzp9ZoSG0sU4pvVdt';
  String errorMessage = '';
  String debugInfo = '';
  bool isDisposed = false; // Track if the widget is disposed

  @override
  void initState() {
    super.initState();
    fetchCurrencyData();
  }

  @override
  void dispose() {
    isDisposed = true; // Mark widget as disposed
    super.dispose();
  }

  Future<void> fetchCurrencyData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      debugInfo = 'Fetching data...';
    });

    // List of currencies you want to show
    List<String> selectedCurrencies = ['EUR', 'GBP', 'USD', 'JPY', 'PKR'];

    try {
      // Fetch the latest exchange rates
      final url = 'https://api.apilayer.com/exchangerates_data/latest?base=USD';
      final response = await http.get(
        Uri.parse(url),
        headers: {'apikey': apiKey},
      ).timeout(Duration(seconds: 10));

      if (!mounted || isDisposed) return; // Check if mounted

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        List<Map<String, dynamic>> currencies = [];

        // Get the date for 30 days ago
        DateTime thirtyDaysAgo = DateTime.now().subtract(Duration(days: 30));
        String historicalDate =
            "${thirtyDaysAgo.year}-${thirtyDaysAgo.month.toString().padLeft(2, '0')}-${thirtyDaysAgo.day.toString().padLeft(2, '0')}";

        // Fetch historical data for 30 days ago
        final historicalUrl =
            'https://api.apilayer.com/exchangerates_data/$historicalDate?base=USD';
        final historicalResponse = await http.get(
          Uri.parse(historicalUrl),
          headers: {'apikey': apiKey},
        ).timeout(Duration(seconds: 10));

        if (historicalResponse.statusCode == 200) {
          var historicalData = json.decode(historicalResponse.body);

          // Calculate change for each selected currency
          data['rates'].forEach((key, value) {
            if (selectedCurrencies.contains(key)) {
              // Get historical rate for the same currency
              var historicalRate = historicalData['rates'][key] ?? 0.0;

              // Calculate percentage change
              double change = 0.0;
              if (historicalRate != 0) {
                change = ((value - historicalRate) / historicalRate) * 100;
              }

              // Format the change value
              String changeText = '${change.toStringAsFixed(2)}%';
              String changeColor = change < 0 ? 'red' : 'green';

              currencies.add({
                'name': key,
                'price': value.toString(),
                'change': changeText, // Show calculated change
                'changeColor': changeColor, // Add color info for display
              });
            }
          });

          setState(() {
            topCurrencies = currencies;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
            errorMessage =
                'Failed to load historical data. Server returned ${historicalResponse.statusCode}';
            debugInfo +=
                '\nHistorical data response: ${historicalResponse.body}';
          });
        }
      } else {
        setState(() {
          isLoading = false;
          errorMessage =
              'Failed to load data. Server returned ${response.statusCode}';
          debugInfo += '\nServer response: ${response.body}';
        });
      }
    } catch (e) {
      if (!mounted || isDisposed) return; // Check if mounted

      setState(() {
        isLoading = false;
        errorMessage = 'An error occurred: $e';
        debugInfo += '\nError details: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'CurrenSee',
          style: TextStyle(
              fontSize: 22,
              color: Color(0xFF1A1A2E),
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Color(0xFF1A1A2E)),
      ),
      drawer: UserDrawer(name: widget.displayName),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Top Currencies',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1A1A2E),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/currency_list');
                      },
                      child: Text(
                        'View All',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF1A1A2E),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pushNamed(context, '/currency_converter');
                      },
                      child: Text(
                        'Converter',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Expanded(
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFF1A1A2E))))
                    : errorMessage.isNotEmpty
                        ? Center(
                            child: Text(
                              errorMessage,
                              style: TextStyle(color: Colors.red),
                              textAlign: TextAlign.center,
                            ),
                          )
                        : ListView.builder(
                            itemCount: topCurrencies.length,
                            itemBuilder: (context, index) {
                              return Card(
                                elevation: 2,
                                margin: EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  title: Text(
                                    topCurrencies[index]['name'],
                                    style: TextStyle(
                                        color: Color(0xFF1A1A2E),
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                    topCurrencies[index]['price'],
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                  trailing: Text(
                                    topCurrencies[index]['change'],
                                    style: TextStyle(
                                      color: topCurrencies[index]
                                                  ['changeColor'] ==
                                              'red'
                                          ? Colors.red
                                          : Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            CurrencyDetailScreen(
                                          currencyName: topCurrencies[index]
                                              ['name'],
                                          currencyChange: topCurrencies[index]
                                              ['change'],
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
        ),
      ),
    );
  }
}

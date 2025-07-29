import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class CurrencyDetailScreen extends StatefulWidget {
  final String currencyName;
  final String currencyChange; // Change as a percentage string

  const CurrencyDetailScreen(
      {Key? key, required this.currencyName, required this.currencyChange})
      : super(key: key);

  @override
  _CurrencyDetailScreenState createState() => _CurrencyDetailScreenState();
}

class _CurrencyDetailScreenState extends State<CurrencyDetailScreen> {
  List<double> chartData = [];
  bool isLoading = true;
  String errorMessage = '';
  String debugInfo = '';
  final String apiKey =
      '19081e2f4c6bbd54281983ad'; // Replace with your actual API key
  double currentRate = 0;
  double? usdValue; // To hold the USD input value
  double? currencyValue; // To hold the selected currency value

  @override
  void initState() {
    super.initState();
    fetchCurrencyData();
  }

  Future<void> fetchCurrencyData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
      debugInfo = 'Fetching data...';
    });

    try {
      // Updated API URL for ExchangeRate API
      final url = 'https://v6.exchangerate-api.com/v6/$apiKey/latest/USD';

      debugInfo += '\nURL: $url';

      final response =
          await http.get(Uri.parse(url)).timeout(Duration(seconds: 10));

      debugInfo += '\nResponse status code: ${response.statusCode}';

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        debugInfo += '\nResponse body: ${json.encode(data)}';

        // Accessing the rate for the specified currency
        if (data['conversion_rates'] != null &&
            data['conversion_rates'][widget.currencyName] != null) {
          currentRate =
              data['conversion_rates'][widget.currencyName].toDouble();

          // Generate simulated historical data
          Random random = Random();
          List<double> simulatedData = List.generate(30, (index) {
            return currentRate * (1 + (random.nextDouble() - 0.5) * 0.02);
          });

          setState(() {
            chartData = simulatedData;
            isLoading = false;
            debugInfo +=
                '\nData fetched successfully. Current rate: $currentRate';
          });
        } else {
          throw Exception('API response does not contain expected data');
        }
      } else {
        throw Exception(
            'Failed to load currency data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage =
            'Failed to load data. Please check your internet connection and try again.';
        debugInfo += '\nError: $e';
      });
    }
  }

  void _onUsdChanged(String value) {
    if (value.isNotEmpty) {
      usdValue = double.tryParse(value);
      if (usdValue != null) {
        currencyValue = usdValue! * currentRate; // Convert USD to currency
      } else {
        currencyValue = null;
      }
    } else {
      usdValue = null;
      currencyValue = null;
    }
    setState(() {});
  }

  void _onCurrencyChanged(String value) {
    if (value.isNotEmpty) {
      currencyValue = double.tryParse(value);
      if (currencyValue != null) {
        usdValue = currencyValue! / currentRate; // Convert currency to USD
      } else {
        usdValue = null;
      }
    } else {
      currencyValue = null;
      usdValue = null;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.currencyName} Details',
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(
                  child:
                      Text(errorMessage, style: TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      _buildChart(),
                      _buildStatistics(),
                      _buildConversionTool(),
                    ],
                  ),
                ),
      backgroundColor: Colors.white,
    );
  }

  Widget _buildHeader() {
    double changePercentage =
        double.tryParse(widget.currencyChange.replaceAll('%', '')) ??
            0; // Convert change to double

    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.currencyName}/USD',
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Text(
                currentRate.toStringAsFixed(4),
                style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              SizedBox(width: 16),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: changePercentage >= 0 ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${changePercentage >= 0 ? '+' : ''}${changePercentage.toStringAsFixed(2)}%',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    return Container(
      height: 300,
      padding: EdgeInsets.all(16),
      child: CustomPaint(
        size: Size.infinite,
        painter: ChartPainter(
          data: chartData,
          color: (double.tryParse(widget.currencyChange.replaceAll('%', '')) ??
                      0) >=
                  0
              ? Colors.green
              : Colors.red,
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Statistics',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem('Open', chartData.first.toStringAsFixed(4)),
              _buildStatItem('High', chartData.reduce(max).toStringAsFixed(4)),
              _buildStatItem('Low', chartData.reduce(min).toStringAsFixed(4)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600])),
        SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
      ],
    );
  }

  Widget _buildConversionTool() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Quick Conversion',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'USD',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: _onUsdChanged,
                  controller: TextEditingController(
                    text: usdValue != null ? usdValue.toString() : '',
                  ),
                  style: TextStyle(color: Colors.black),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: widget.currencyName,
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: _onCurrencyChanged,
                  controller: TextEditingController(
                    text: currencyValue != null ? currencyValue.toString() : '',
                  ),
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget _buildNewsSection() {
  //   return Container(
  //     padding: EdgeInsets.all(16),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Text('Related News',
  //             style: TextStyle(
  //                 fontSize: 20,
  //                 fontWeight: FontWeight.bold,
  //                 color: Colors.black)),
  //         SizedBox(height: 16),
  //         _buildNewsItem(
  //             'Currency markets remain stable amid global uncertainties',
  //             '2 hours ago'),
  //         _buildNewsItem(
  //             'Economic report shows strong performance for ${widget.currencyName}',
  //             '5 hours ago'),
  //         _buildNewsItem(
  //             'Analysts predict positive outlook for ${widget.currencyName} in coming months',
  //             '1 day ago'),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildNewsItem(String title, String time) {
  //   return Padding(
  //     padding: const EdgeInsets.only(bottom: 16.0),
  //     child: Row(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         Container(
  //           width: 60,
  //           height: 60,
  //           decoration: BoxDecoration(
  //             color: Colors.grey[200],
  //             borderRadius: BorderRadius.circular(8),
  //           ),
  //           child: Icon(Icons.article, color: Colors.grey),
  //         ),
  //         SizedBox(width: 16),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(title,
  //                   style: TextStyle(
  //                       fontSize: 16,
  //                       fontWeight: FontWeight.bold,
  //                       color: Colors.black)),
  //               SizedBox(height: 4),
  //               Text(time, style: TextStyle(color: Colors.grey[600])),
  //             ],
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}

class ChartPainter extends CustomPainter {
  final List<double> data;
  final Color color;

  ChartPainter({required this.data, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final path = Path();
    final minY = data.reduce(min);
    final maxY = data.reduce(max);
    final yRange = maxY - minY;

    for (int i = 0; i < data.length; i++) {
      final x = size.width * i / (data.length - 1);
      final y = size.height - ((data[i] - minY) / yRange) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Draw filled area
    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

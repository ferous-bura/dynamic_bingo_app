import 'package:dynamic_bingo_app/auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dynamic_bingo_app/constants.dart';
// import 'package:dynamic_bingo_app/webpage.dart';

import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool isLoading = true;
  List<DailyRecord> dailyRecords = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(USER_DATA_URL),
        // Uri.parse(dummy_data_url),
        headers: {
          'Authorization': 'Token $token', // Use 'Token' here
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        // Decode the response as a Map
        Map<String, dynamic> responseData = json.decode(response.body);
        // Extract the daily records list from the response data. Adjust the key if necessary.
        List<dynamic> recordsJson = responseData['daily_records'] ?? [];

        setState(() {
          dailyRecords =
              recordsJson.map((item) => DailyRecord.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching data: $e');
    }
  }

  Future<void> fetchData2() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      final response = await http.get(
        Uri.parse(USER_DATA_URL),
        // Uri.parse(dummy_data_url),
        headers: {
          'Authorization': 'Token $token', // Use 'Token' here
          // 'Authorization': 'Bearer $token', // Include token in the headers
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        setState(() {
          dailyRecords =
              data.map((item) => DailyRecord.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              AuthService authService = AuthService();
              await authService.logout(context);
            },
          ),
        ],
      ),
      body:
          isLoading
              // ? Center(child: WebViewPage(url: API_URL))
              ? Center(child: CircularProgressIndicator())
              : dailyRecords.isEmpty
              ? Center(child: Text('No data available'))
              : ListView.builder(
                itemCount: dailyRecords.length,
                itemBuilder: (context, index) {
                  final record = dailyRecords[index];
                  return Card(
                    child: ListTile(
                      title: Text('Date: ${record.date}'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Transactions: ${record.totalTransactions}',
                          ),
                          Text('Total Amount: \$${record.totalAmount}'),
                        ],
                      ),
                    ),
                  );
                },
              ),
    );
  }
}

class DailyRecord {
  final String date;
  final int totalTransactions;
  final double totalAmount;

  DailyRecord({
    required this.date,
    required this.totalTransactions,
    required this.totalAmount,
  });
  factory DailyRecord.fromJson(Map<String, dynamic> json) {
    return DailyRecord(
      date: json['date'] ?? '', // Default to an empty string if date is null
      totalTransactions: json['totalTransactions'] ?? 0, // Default to 0 if null
      totalAmount:
          (json['totalAmount'] ?? 0.0).toDouble(), // Default to 0.0 if null
    );
  }
}

import 'package:dynamic_bingo_app/user/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String baseUrl =
      "https://your-backend.pythonanywhere.com/api"; // Update this URL

  Future<String?> signUp(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      if (response.statusCode == 201) {
        return "Success! Please log in.";
      } else {
        return "Error: ${jsonDecode(response.body)['detail']}";
      }
    } catch (e) {
      return "Error: $e";
    }
  }

  Future<String?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"username": username, "password": password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);

        return "Success";
      } else {
        return "Error: ${jsonDecode(response.body)['detail']}";
      }
    } catch (e) {
      return "Error: $e";
    }
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
}

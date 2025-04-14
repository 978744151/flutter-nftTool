import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import '../router/router.dart';
// ignore: depend_on_referenced_packages
import 'package:fluttertoast/fluttertoast.dart';

class HttpClient {
  static const String baseUrl = 'http://127.0.0.1:5001/api/v1';
  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<dynamic> get(String path) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: headers,
    );
    return _handleResponse(response);
  }

  static Future<dynamic> post(String path, {Map<String, dynamic>? body}) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: json.encode(body),
    );
    return _handleResponse(response);
  }

  static dynamic _handleResponse(http.Response response) {
    try {
      final data = json.decode(response.body);
      print(response);
      if (response.statusCode == 401) {
        // _showErrorMessage('登录已过期，请重新登录');

        // ignore: depend_on_referenced_packages
        Fluttertoast.showToast(
            msg: "登录已过期，请重新登录",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            backgroundColor: Colors.black87,
            textColor: Colors.white,
            fontSize: 16.0);
        final context = router.routerDelegate.navigatorKey.currentContext;

        if (context != null) {
          router.go('/login');
        }
        throw Exception('未授权');
      }

      if (response.statusCode != 200 || data['success'] != true) {
        final message = data['error'] ?? '请求失败';
        _showErrorMessage(message);
        throw Exception(message);
      }

      return data;
    } catch (e) {
      // if (e.toString().contains('SocketException') ||
      //     e.toString().contains('HandshakeException')) {
      //   _showErrorMessage('网络连接不安全或无法访问，请检查网络设置');
      // } else if (e.toString().contains('TimeoutException')) {
      //   _showErrorMessage('请求超时，请稍后重试');
      // } else {
      //   _showErrorMessage('网络请求失败：${e.toString()}');
      // }
      rethrow;
    }
  }

  static void _showErrorMessage(String message) {
    final context = router.routerDelegate.navigatorKey.currentContext;
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red[700],
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 100, // 计算距离顶部的位置
            left: 20,
            right: 20,
          ),
        ),
      );
    }
  }
}

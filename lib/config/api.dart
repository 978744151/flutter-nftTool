import 'package:http/http.dart' as http;
import 'dart:convert';
import 'nft_api.dart';

class ApiConfig {
  static const String baseUrl = 'http://8.155.53.210:3000/api/v1';
  static String getFullPath(String path) => baseUrl + path;
}

class Api {
  static final _headers = {'Content-Type': 'application/json'};

  static Future<dynamic> _request(
    String path, {
    String method = 'GET',
    Map<String, dynamic>? data,
  }) async {
    try {
      late http.Response response;
      final url = ApiConfig.getFullPath(path);

      switch (method) {
        case 'GET':
          response = await http.get(Uri.parse(url), headers: _headers);
          break;
        case 'POST':
          response = await http.post(
            Uri.parse(url),
            headers: _headers,
            body: data != null ? json.encode(data) : null,
          );
          break;
      }

      final responseData = json.decode(response.body);
      return response.statusCode == 200 ? responseData : throw responseData;
    } catch (e) {
      return {'success': false, 'message': e.toString(), 'data': null};
    }
  }

  static Future<dynamic> get(String path) => _request(path);

  static Future<dynamic> post(String path, {Map<String, dynamic>? data}) =>
      _request(path, method: 'POST', data: data);
}

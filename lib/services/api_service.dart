import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  final String baseUrl = dotenv.env['API_BASE_URL'] ?? '';

  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    Uri uri;
    if (queryParameters != null && queryParameters.isNotEmpty) {
      uri = Uri.parse('$baseUrl$endpoint').replace(
        queryParameters: queryParameters.map(
          (k, v) => MapEntry(k, v.toString()),
        ),
      );
    } else {
      uri = Uri.parse('$baseUrl$endpoint');
    }

    final response = await http.get(uri, headers: headers);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error: ${response.statusCode}');
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    return await postWithHeaders(endpoint, data);
  }

  Future<dynamic> postWithHeaders(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  }) async {
    final defaultHeaders = {'Content-Type': 'application/json'};
    final mergedHeaders = headers != null
        ? {...defaultHeaders, ...headers}
        : defaultHeaders;
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: mergedHeaders,
      body: jsonEncode(data),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      String errorMsg = 'Error: ${response.statusCode}';
      if (response.body.isNotEmpty) {
        try {
          final errorJson = jsonDecode(response.body);
          if (errorJson is Map && errorJson.containsKey('message')) {
            errorMsg = errorJson['message'];
          } else {
            errorMsg = response.body;
          }
        } catch (_) {
          errorMsg = response.body;
        }
      }
      throw Exception(errorMsg);
    }
  }
}

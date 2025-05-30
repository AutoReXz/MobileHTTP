import 'dart:convert';
import 'package:http/http.dart' as http;

class BaseNetwork {
  static const String baseUrl = 'https://681388b3129f6313e2119693.mockapi.io/api/v1/movie';

  static Future<List<dynamic>> getList(String endpoint) async {
    final response = await http.get(Uri.parse('$baseUrl$endpoint'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  static Future<Map<String, dynamic>> getDetail(String endpoint, int id) async {
    final response = await http.get(Uri.parse('$baseUrl$endpoint/$id'));

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load detail data: ${response.statusCode}');
    }
  }
}

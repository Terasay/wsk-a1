import 'dart:convert';
import 'package:http/http.dart' as http;

const String baseUrl = 'http://10.0.2.2:3000';

Future<List<dynamic>> fetchUsers() async {
  final url = Uri.parse('$baseUrl/users');

  final response = await http.get(url);

  if (response.statusCode != 200) {
    throw Exception('Ошибка сервера');
  }

  return jsonDecode(response.body) as List<dynamic>;
}

Future<dynamic> fetchFollows() async {
  final url = Uri.parse('$baseUrl/api/follows');

  final response = await http.get(url);

  if (response.statusCode != 200) {
    throw Exception('Офыбка');
  }

  return jsonDecode(response.body);
}
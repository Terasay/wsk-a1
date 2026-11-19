import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<dynamic>> fetchUsers() async {
  final url = Uri.parse('http://10.0.2.2:3000/users');

  final response = await http.get(url);

  if (response.statusCode != 200) {
    throw Exception('Ошибка сервера');
  }

  return jsonDecode(response.body) as List<dynamic>;
}
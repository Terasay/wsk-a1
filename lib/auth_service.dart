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

Future<Map<String, dynamic>> fetchUser(String id) async {
  final url = Uri.parse('$baseUrl/api/users/$id');
  final response = await http.get(url);

  if (response.statusCode != 200) {
    throw Exception('Не удалось загрузить профиль');
  }

  return jsonDecode(response.body) as Map<String, dynamic>;
}

Future <Map<String, dynamic>> deleteDiscovery(
  String userId,
  String postId,
) async {
  final profile = await fetchUser(userId);
  final posts = (profile['discoveries'] as List?) ?? [];

  final remainingPosts = posts
    .where((post) => post['id'].toString() != postId)
    .toList();

    final response = await http.patch(
      Uri.parse('$baseUrl/api/users/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'discoveries': remainingPosts}),
    );

    if (response.statusCode != 200) {
      throw Exception('aaa');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
}
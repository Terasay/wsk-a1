import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DetailPage extends StatefulWidget {
  final Map post;
  final Map? currentUser;

  const DetailPage({
    super.key,
    required this.post,
    this.currentUser,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  bool _showFloating = false;
  final TextEditingController _commentController = TextEditingController();
  final List _comments = [];

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    final postId = widget.post['id'];
    final url = Uri.parse('http://10.0.2.2:3000/api/comments?postId=$postId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      setState(() {
        _comments.clear();
        for (var item in data) {
          _comments.add({
            'author': (item['author'] ?? 'User').toString(),
            'text': (item['text'] ?? '').toString(),
          });
        }
      });
    }
  }

  Future<void> _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final currentAuthor = {widget.currentUser?['username'] ?? 'Me'}.toString();
    final url = Uri.parse('http://10.0.2.2:3000/api/comments');

    final response = await http.post(
      url,
      headers: {'Content-Type': "application/json"},
      body: jsonEncode({
        'postId': widget.post['id'],
        'author': currentAuthor,
        'text': text,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      setState(() {
        _comments.add({
          'author': currentAuthor,
          'text': text,
        });
        _commentController.clear();
      });
    }
  }

  List<String> _getTags(String text) {
    // 1. Переводим в нижний регистр, убираем точки/запятые и делим по пробелам
    final words = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.length > 3); // Отсекаем короткие предлоги вроде in, of, the, and

    // 2. Считаем, сколько раз встречается каждое слово
    final counts = <String, int>{};
    for (var w in words) {
      counts[w] = (counts[w] ?? 0) + 1;
    }

    // 3. Сортируем слова от самого частого к редкому и берём первые 3
    final sorted = counts.keys.toList()
      ..sort((a, b) => counts[b]!.compareTo(counts[a]!));

    return sorted.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    final author = (widget.post['author'] ?? 'User').toString();
    final title = (widget.post['title'] ?? 'Title').toString();
    final media = (widget.post['media'] as List?) ?? [];
    final subtitle = (widget.post['subtitle'] ?? 'Subtitle').toString();
    final description = (widget.post['description'] ?? 'Description').toString();
    final publishTime = (widget.post['publishTime'] ?? '2026-08-01 12:00').toString();

    final tags = _getTags(description);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox.expand(
          child: Stack(
            children: [
              // 1-й слой: прокручиваемая страница
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Шапка
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back, color: Colors.black),
                          ),
                          const CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.grey,
                            child: Icon(Icons.person_outline, color: Colors.black54),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            author,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),

                    // Медиа-блок со свайпом
                    Container(
                      height: 260,
                      width: double.infinity,
                      color: Colors.black,
                      child: media.isEmpty
                          ? const Center(
                              child: Text('No media', style: TextStyle(color: Colors.white)),
                            )
                          : PageView.builder(
                              itemCount: media.length,
                              itemBuilder: (context, index) {
                                final item = media[index] as Map;
                                final isVideo = item['type'] == 'video';

                                return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Text(
                                      isVideo
                                          ? 'Video (${index + 1}/${media.length})'
                                          : 'Image (${index + 1}/${media.length})',
                                      style: const TextStyle(color: Colors.white, fontSize: 20),
                                    ),
                                    if (isVideo)
                                      const Positioned(
                                        right: 16,
                                        bottom: 16,
                                        child: Icon(
                                          Icons.play_circle_outline,
                                          color: Colors.white,
                                          size: 30,
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                    ),

                    // Описание и комментарии
                    Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            children: tags.map((tag) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                color: Colors.grey,
                                child: Text(tag, style: const TextStyle(fontSize: 12)),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() => _showFloating = !_showFloating);
                                },
                                child: const Text('Floating window'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),

                          Text(
                            subtitle,
                            style: const TextStyle(fontSize: 15, color: Colors.black54),
                          ),
                          const SizedBox(height: 10),

                          Text(
                            description,
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 16),

                          Text(
                            publishTime,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          ),

                          const Divider(height: 28),

                          // Счётчик комментариев
                          Text(
                            '${_comments.length} comments',
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                          const SizedBox(height: 10),

                          // Поле ввода комментария
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _commentController,
                                  decoration: const InputDecoration(
                                    hintText: 'Write a comment...',
                                    isDense: true,
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.send, color: Colors.black),
                                onPressed: _addComment,
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Список добавленных комментариев
                          ..._comments.map((comment) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CircleAvatar(
                                    radius: 14,
                                    backgroundColor: Colors.grey[300],
                                    child: const Icon(
                                      Icons.person_outline,
                                      size: 16,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          comment['author'] ?? 'User',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          comment['text'] ?? '',
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 2-й слой: плавающее окно поверх страницы
              if (_showFloating)
                Positioned(
                  right: 16,
                  bottom: 20,
                  child: Container(
                    width: 160,
                    height: 110,
                    color: Colors.black,
                    child: Stack(
                      children: [
                        const Center(
                          child: Text(
                            'Mini Media',
                            style: TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            onPressed: () => setState(() => _showFloating = false),
                            icon: const Icon(Icons.close, color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
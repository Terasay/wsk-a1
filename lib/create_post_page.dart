import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreatePostPage extends StatefulWidget {
  final Map currentUser;
  const CreatePostPage({super.key, required this.currentUser});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _titleController = TextEditingController();
  final _subtitleController = TextEditingController();
  final _descController = TextEditingController();
  final List _media = [];
  bool _isSaving = false;

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    final title = _titleController.text.trim();
    final subtitle = _subtitleController.text.trim();
    final description = _descController.text.trim();

    if (title.isEmpty || description.isEmpty || _media.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполни заголовок, описание и добавь хотя бы 1 медиа')),
      );
      return;
    }

    setState(() => _isSaving = true);

    final userId = widget.currentUser['id'].toString();
    final userUrl = Uri.parse('http://10.0.2.2:3000/api/users/$userId');

    // 1. Забираем актуальный список постов этого пользователя
    final getRes = await http.get(userUrl);
    if (getRes.statusCode != 200) {
      setState(() => _isSaving = false);
      return;
    }

    final userData = jsonDecode(getRes.body) as Map<String, dynamic>;
    final List discoveries = List.from(userData['discoveries'] ?? []);

    // 2. Формируем новый пост в формате db.json
    final now = DateTime.now();
    final publishTime =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')} '
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:00';

    discoveries.add({
      'id': 'd${now.millisecondsSinceEpoch}',
      'title': title,
      'subtitle': subtitle.isEmpty ? 'Travel note' : subtitle,
      'description': description,
      'publishTime': publishTime,
      'media': _media,
    });

    // 3. Обновляем только поле discoveries у пользователя через PATCH
    final patchRes = await http.patch(
      userUrl,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'discoveries': discoveries}),
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (patchRes.statusCode == 200) {
      Navigator.pop(context, true); // Возвращаем true как сигнал обновить ленту
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('New Post', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Кнопки добавления фото/видео заглушек
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => setState(() => _media.add({'type': 'image', 'url': ''})),
                  icon: const Icon(Icons.image_outlined, color: Colors.black),
                  label: const Text('+ Image', style: TextStyle(color: Colors.black)),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: () => setState(() => _media.add({'type': 'video', 'url': ''})),
                  icon: const Icon(Icons.videocam_outlined, color: Colors.black),
                  label: const Text('+ Video', style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Список выбранных медиа с возможностью удалить
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(_media.length, (index) {
                final isVideo = _media[index]['type'] == 'video';
                return Chip(
                  label: Text('${isVideo ? 'Video' : 'Image'} #${index + 1}'),
                  onDeleted: () => setState(() => _media.removeAt(index)),
                );
              }),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _subtitleController,
              decoration: const InputDecoration(
                labelText: 'Subtitle',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                ),
                onPressed: _isSaving ? null : _publish,
                child: Text(_isSaving ? 'Publishing...' : 'Publish'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
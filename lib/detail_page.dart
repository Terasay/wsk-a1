import 'package:flutter/material.dart';

class DetailPage extends StatefulWidget{
  final Map post;
  final Map? currentUser;

  const DetailPage({
    super.key,
    required this.post,
    this.currentUser
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

  class _DetailPageState extends State<DetailPage> {
    bool _showFloating = false;
    final TextEditingController _commentController = TextEditingController();
    final List _comments = [];

    @override
    void dispose() {
      _commentController.dispose();
      super.dispose();
    }

    void _addComment() {
      final text = _commentController.text.trim();
      if (text.isEmpty) return;

      final currentAuthor = (widget.currentUser?['username'] ?? 'Me').toString();
      setState(() {
        _comments.add({
          'author': currentAuthor,
          'text': text,
        });
        _commentController.clear();
      });
    }
  

  @override
  Widget build(BuildContext context) {
    final author = (widget.post['author'] ?? 'User').toString();
    final title = (widget.post['title'] ?? 'Title').toString();
    final media = (widget.post['media'] as List?) ?? [];
    final subtitle = (widget.post['subtitle'] ?? 'Subtitle').toString();
    final description = (widget.post['description'] ?? 'Description').toString();
    final publishTime = (widget.post['publishtime'] ?? '2026-08-01 12:00').toString();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsetsGeometry.symmetric(horizontal: 8, vertical: 6),
                    child: Row(
                      children: [
                        IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: Colors.black),),
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.grey,
                          child: const Icon(Icons.person_outline, color: Colors.black54),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          author,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        )
                      ],
                    ),
                  ),

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
                      )
                  ),

                  Padding(
                    padding: const EdgeInsetsGeometry.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          children: ['Tag1', 'Tag2', 'Tag3'].map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            color: Colors.grey,
                            child: Text(tag, style: const TextStyle(fontSize: 12)),
                          );
                          }).toList()
                        ),
                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: 
                                Text(
                                  title,
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                        SizedBox(height: 16),

                        Text(
                          publishTime,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        )
                      ],
                    ),
                  ),

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
                              child: Text('Mini Media', style: TextStyle(color: Colors.white, fontSize: 13),),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(onPressed: () => setState(() => _showFloating = false), icon: const Icon(Icons.close, color: Colors.white, size: 18)),
                            )
                          ],
                        ),
                      ),
                    )
                ],
              ),
            )
          ],
        )

        
      ),
    );
  }
}
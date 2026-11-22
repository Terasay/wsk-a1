import 'package:a1/detail_page.dart';
import 'package:a1/login_page.dart';
import 'package:flutter/material.dart';
import 'auth_service.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key, required this.currentUser});

  final Map currentUser;

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  late final Future<dynamic> _followsFuture;
  late Future<Map<String, dynamic>> _profileFuture;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _followsFuture = fetchFollows();
    _profileFuture = fetchUser(widget.currentUser['id'].toString());
  }

  Future<void> _deletePost(String postId) async {
    final userId = widget.currentUser['id'].toString();
    setState(() => _isDeleting = true);

    try {
      final updatedProfile = await deleteDiscovery(userId, postId);
      if (!mounted) return;

      setState(() {
        _profileFuture = Future.value(updatedProfile);
      });
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('aaa'))
      );
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = widget.currentUser;
    final name = currentUser['nickname'] ??
      currentUser['username'] ??
      'User';

    final avatar = currentUser['avatar'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My'),
        actions: [
          TextButton(onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginPage()),
              (route) => false,
            );
          },
          child: const Text('Logout'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: double.infinity,
            child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 36,
                foregroundImage: avatar is String && avatar.isNotEmpty
                  ? NetworkImage(avatar)
                  : null,
                child: const Icon(Icons.person_outline, size: 32),
              ),
              const SizedBox(height: 12),
              Text(name.toString()),

              const SizedBox(height: 16),

              FutureBuilder<dynamic>(
                future: _followsFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Не загрузились подписки');
                  }
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final myId = currentUser['id'].toString();
                  final outgoing = <String>{};
                  final incoming = <String>{};

                  for (final follow in snapshot.data as List) {
                    final from = follow['userId'].toString();
                    final to = follow['followingId'].toString();

                    if (from == myId) {
                      outgoing.add(to);
                    }
                    if (to == myId) {
                      incoming.add(from);
                    }
                  }

                  final mutual = outgoing.intersection(incoming);
                  return Text(
                    'Подписки: ${outgoing.length} Взаимные: ${mutual.length}',
                  );
                },
              ),

              const SizedBox(height: 24),

              const Text('Все публикации'),

              FutureBuilder<Map<String, dynamic>>(
                future: _profileFuture,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Text('Не удалось загрузить публикации');
                  }
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  }

                  final profile = snapshot.data!;
                  final posts = (profile['discoveries'] as List?) ?? [];

                  if (posts.isEmpty) {
                    return const Text('Публикаций пока нет');
                  }

                  return Column(
                    children: [
                      for (final post in posts)
                        ListTile(
                          title: Text(post['title'].toString()),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline),
                            onPressed: _isDeleting
                              ? null
                              : () => _deletePost(post['id'].toString()),
                          ),
                          onTap: () {
                            final detailPost = Map<String, dynamic>.from(post as Map);
                            detailPost['author'] = name.toString();

                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DetailPage(
                                  post: detailPost,
                                  currentUser: currentUser,
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  );
                },
              ),
            ],
          )
        )
      )

    );
  }
}
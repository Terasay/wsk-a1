import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'detail_page.dart';
import 'create_post_page.dart';
import 'my_page.dart';


class HomePage extends StatefulWidget {
  final Map currentUser;
  const HomePage({super.key, required this.currentUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoose = false;
  final Map<String, String> _followIds = {};
  final Map<String, String> _userNames = {};
  final List _posts = [];

  @override
  void initState() {
    super.initState();
    _loadPosts();
    _loadFollows();
  }

  Future<void> _loadPosts() async {
    final url = Uri.parse('http://10.0.2.2:3000/api/users');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List users = jsonDecode(response.body);
      final List loadedPosts = [];

      for (var user in users) {
        final authorName = (user['nickname'] ?? user['username'] ?? 'User').toString();
        final authorId = (user['id'] ?? '').toString();
        final discoveries = (user['discoveries'] as List?) ?? [];
        _userNames[authorId] = authorName;

        for (var item in discoveries) {
          final post = Map<String, dynamic>.from(item as Map);
          post['author'] = authorName;
          post['authorId'] = authorId;
          loadedPosts.add(post);
        }
      }

      setState(() {
        _posts
          ..clear()
          ..addAll(loadedPosts);
      });
    }
  }

  Future<void> _loadFollows() async {
    final myId = (widget.currentUser['id'] ?? '').toString();
    final url = Uri.parse('http://10.0.2.2:3000/api/follows?userId=$myId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      setState(() {
        _followIds.clear();
        for (var item in data) {
          _followIds[item['followingId'].toString()] = item['id'].toString();
        }
      });
    }
  }

  Future<void> _toggleFollow(String targetUserId) async {
    final myId = (widget.currentUser['id'] ?? '').toString();

    if (_followIds.containsKey(targetUserId)) {
      // Отписываемся: удаляем запись по её id
      final recordId = _followIds[targetUserId]!;
      final res = await http.delete(
        Uri.parse('http://10.0.2.2:3000/api/follows/$recordId'),
      );
      if (res.statusCode == 200) {
        setState(() => _followIds.remove(targetUserId));
      }
    } else {
      // Подписываемся: создаём новую запись в follows
      final res = await http.post(
        Uri.parse('http://10.0.2.2:3000/api/follows'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': myId, 'followingId': targetUserId}),
      );
      if (res.statusCode == 201 || res.statusCode == 200) {
        final created = jsonDecode(res.body);
        setState(() => _followIds[targetUserId] = created['id'].toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          toolbarHeight: 0,
          backgroundColor: Colors.white,
          elevation: 0,
          bottom: const TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal, fontSize: 15),
            indicatorColor: Colors.black,
            indicatorWeight: 2.5,
            tabs: [
              Tab(text: 'Explore'),
              Tab(text: 'Following'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildExploreTab(),
            _buildFollowingTab(),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.grey.shade300)),
          ),
          child: BottomNavigationBar(
            currentIndex: 0,
            backgroundColor: Colors.white,
            elevation: 0,
            selectedItemColor: Colors.black,
            unselectedItemColor: Colors.grey,
            selectedFontSize: 14,
            unselectedFontSize: 14,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            onTap: (index) async {
              if (index == 1) {
                final created = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreatePostPage(currentUser: widget.currentUser),
                  ),
                );

                if (created == true) {
                  _loadPosts();
                }
              }

              else if (index == 2) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => MyPage(currentUser: widget.currentUser),
                  ),
                );
              }
            },
            items: const [
              BottomNavigationBarItem(
                icon: SizedBox.shrink(),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_circle_outline, color: Colors.black, size: 28),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: SizedBox.shrink(),
                label: 'My',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Вкладка 1: Explore (Обзор)
  Widget _buildExploreTab() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _modeButton('Default', !_isLoose, () => setState(() => _isLoose = false)),
              const SizedBox(width: 8),
              _modeButton('Loose', _isLoose, () => setState(() => _isLoose = true)),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _isLoose
                ? ListView.separated(
                    itemCount: _posts.length,
                    separatorBuilder: (_, __) => const Divider(height: 24),
                    itemBuilder: (context, index) => _buildLooseCard(_posts[index]),
                  )
                : GridView.builder(
                    itemCount: _posts.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 14,
                      childAspectRatio: 0.72,
                    ),
                    itemBuilder: (context, index) => _buildCard(_posts[index]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _modeButton(String text, bool active, VoidCallback onTap) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: active ? Colors.grey[400] : Colors.grey[300],
        foregroundColor: Colors.black,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
      onPressed: onTap,
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }

  // Вкладка 2: Following (Подписки)
  Widget _buildFollowingTab() {
    final followedIds = _followIds.keys.toList();

    final followingPosts = _posts
      .where((post) => _followIds.containsKey(post['authorId'].toString()))
      .toList();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          SizedBox(
            height: 75,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: followedIds.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.grey[300],
                        child: const Icon(Icons.person_outline, color: Colors.black54),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _userNames[followedIds[index]] ?? 'User',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: GridView.builder(
              itemCount: followingPosts.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 14,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, index) {
                return _buildCard(followingPosts[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Карточка для сетки в 2 колонки (Explore Default и Following)
  Widget _buildCard(Map post) {
    final title = (post['title'] ?? '').toString();
    final author = (post['author'] ?? '').toString();
    final media = post['media'] as List;
    final authorId = (post['authorId'] ?? '').toString();
    final myId = (widget.currentUser['id'] ?? '').toString();
    final isFollowing = _followIds.containsKey(authorId);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DetailPage(
            post: post,
            currentUser: widget.currentUser,)
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: media.isEmpty
              ? Container(color: Colors.grey)
              : _mediaBox(media[0] as Map),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: Colors.grey[300],
                child: const Icon(Icons.person_outline, size: 15, color: Colors.black54),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  author,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (authorId != myId) _followChip(authorId, isFollowing),
            ],
          ),
        ],
      ),
    );
  }

  // Карточка для одноколоночного режима Loose
  Widget _buildLooseCard(Map post) {
    final title = (post['title'] ?? '').toString();
    final author = (post['author'] ?? '').toString();
    final media = post['media'] as List;
    final authorId = (post['authorId'] ?? '').toString();
    final myId = (widget.currentUser['id'] ?? '').toString();
    final isFollowing = _followIds.containsKey(authorId);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 13,
              backgroundColor: Colors.grey[300],
              child: const Icon(Icons.person_outline, size: 16, color: Colors.black54),
            ),
            const SizedBox(width: 8),
            Text(author, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 190,
          child: _buildLooseMedia(media),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
            if (authorId != myId) _followChip(authorId, isFollowing),
          ],
        ),
      ],
    );
  }

  // Раскладка картинок/видео в режиме Loose (1, 2, 3, 4 и >4)
  Widget _buildLooseMedia(List media) {
    if (media.length == 1) {
      return _mediaBox(media[0] as Map);
    }
    if (media.length == 2) {
      return Row(
        children: [
          Expanded(child: _mediaBox(media[0] as Map)),
          const SizedBox(width: 2),
          Expanded(child: _mediaBox(media[1] as Map)),
        ],
      );
    }
    if (media.length == 3) {
      return Row(
        children: [
          Expanded(child: _mediaBox(media[0] as Map)),
          const SizedBox(width: 2),
          Expanded(
            child: Column(
              children: [
                Expanded(child: _mediaBox(media[1] as Map)),
                const SizedBox(height: 2),
                Expanded(child: _mediaBox(media[2] as Map)),
              ],
            ),
          ),
        ],
      );
    }

    final extra = media.length - 4;
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(child: _mediaBox(media[0] as Map)),
              const SizedBox(width: 2),
              Expanded(child: _mediaBox(media[1] as Map)),
            ],
          ),
        ),
        const SizedBox(height: 2),
        Expanded(
          child: Row(
            children: [
              Expanded(child: _mediaBox(media[2] as Map)),
              const SizedBox(width: 2),
              Expanded(
                child: _mediaBox(media[3] as Map, extraCount: extra > 0 ? extra : null),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Одна плитка медиа (Image или Video + значок Play + затемнение "+N")
  Widget _mediaBox(Map item, {int? extraCount}) {
    final isVideo = item['type'] == 'video';

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[300],
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Text(
              isVideo ? 'Video' : 'Image',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          if (isVideo)
            const Positioned(
              right: 8,
              bottom: 8,
              child: Icon(Icons.play_circle_outline, size: 24, color: Colors.black87),
            ),
          if (extraCount != null)
            Container(
              color: Colors.black54,
              alignment: Alignment.center,
              child: Text(
                '+$extraCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Кнопка Follow / Following
  Widget _followChip(String authorId, bool isFollowing) {
    return GestureDetector(
      onTap: () => _toggleFollow(authorId),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          isFollowing ? 'Following' : 'Follow',
          style: const TextStyle(fontSize: 11, color: Colors.black87),
        ),
      ),
    );
  }
}
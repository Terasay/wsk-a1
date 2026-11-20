import 'package:flutter/material.dart';
import 'detail_page.dart';

class HomePage extends StatefulWidget {
  final Map currentUser;
  const HomePage({super.key, required this.currentUser});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isLoose = false;
  final _followedUsers = {'User1', 'User2'};

  final _posts = [
    {
      'title': 'Forbidden City',
      'author': 'User1',
      'media': [
        {'type': 'image'},
      ],
    },
    {
      'title': 'Great Wall',
      'author': 'User2',
      'media': [
        {'type': 'video'},
        {'type': 'image'},
      ],
    },
    {
      'title': 'Terracotta Army',
      'author': 'User3',
      'media': [
        {'type': 'image'},
        {'type': 'image'},
        {'type': 'video'},
      ],
    },
    {
      'title': 'Summer Palace',
      'author': 'User1',
      'media': [
        {'type': 'video'},
        {'type': 'image'},
        {'type': 'image'},
        {'type': 'video'},
        {'type': 'image'},
        {'type': 'image'},
      ],
    },
  ];

  void _toggleFollow(String author) {
    setState(() {
      if (_followedUsers.contains(author)) {
        _followedUsers.remove(author);
      } else {
        _followedUsers.add(author);
      }
    });
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
            onTap: (index) {
              debugPrint('Нажали кнопку: $index');
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
    final followedList = _followedUsers.toList();

    final followingPosts = _posts
        .where((post) => _followedUsers.contains(post['author']))
        .toList();

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          SizedBox(
            height: 75,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: followedList.length,
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
                        followedList[index],
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
    final isFollowing = _followedUsers.contains(author);

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
            child: _mediaBox(media[0] as Map),
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
              _followChip(author, isFollowing),
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
    final isFollowing = _followedUsers.contains(author);

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
            _followChip(author, isFollowing),
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
  Widget _followChip(String author, bool isFollowing) {
    return GestureDetector(
      onTap: () => _toggleFollow(author),
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
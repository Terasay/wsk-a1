import 'package:flutter/material.dart';

class HomePage extends StatelessWidget{
  const HomePage({super.key});

  @override
  Widget build (BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Explore'),
              Tab(text: 'Following'),
            ],
          ),
        ),

        body: TabBarView(
          children: [
            _buildExploreTab(),
            const Center(child: Text('Following')),
          ],
        ),

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0,
          onTap: (index) {
            print('f');
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home),
            label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline),
            label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.person),
            label: 'My'),
          ],
        ),
      ),
    );
  }

  Widget _buildExploreTab() {
    return Padding(
      padding: const EdgeInsetsGeometry.all(12),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: const Text('Default'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Loose'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Expanded(
            child: GridView.builder(
              itemCount: 6,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                childAspectRatio: 0.75,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, index) {
                return _buildCard(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            color: Colors.grey,
            alignment: Alignment.center,
            child: Text('Image ${index + 1}'),
          ),
        ),

        const SizedBox(height: 6),

        Text(
          'Title ${index + 1}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 4),


        Row(
          children: [
            const CircleAvatar(
              radius: 12,
              child: Icon(Icons.person, size: 14),
            ),
            
            const SizedBox(width: 6),

            const Expanded(
              child: Text(
                'Nickname',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              color: Colors.grey,
              child: const Text('Follow', style: TextStyle(fontSize: 12)),
            ),
          ],
        )
      ],
    );
  }
}

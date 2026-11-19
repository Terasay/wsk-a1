import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('HeritageSpot'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Explore'),
              Tab(text: 'Following'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Center(child: Text('Explore')),
            Center(child: Text('Following')),
          ],
        ),
      ),
    );
  }
}
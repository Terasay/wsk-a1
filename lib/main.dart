import 'package:flutter/material.dart';
import 'login_page.dart';

//начало приложения
void main() {
  runApp(const HeritageSpotApp()); 
}

//первый класс
class HeritageSpotApp extends StatelessWidget {
  const HeritageSpotApp({super.key}); 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HeritageSpot',
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}
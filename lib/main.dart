import 'package:flutter/material.dart';
import 'screens/menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PUZZLE COLOR',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 36, 36, 36),
      ),
      home: const MenuScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

import 'package:flutter/material.dart';
import '../widgets/game_board.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Color Link'),
        backgroundColor: Color.fromARGB(255, 36, 36, 36),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        centerTitle: true,
      ),
      body: Center(child: GameBoard()),
      backgroundColor: const Color.fromARGB(255, 36, 36, 36),
    );
  }
}

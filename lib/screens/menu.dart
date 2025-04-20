import 'package:flutter/material.dart';
import '../widgets/game_board.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  void navigateToGame(
    BuildContext context,
    String levelName,
    int rows,
    int cols,
    int initialTime,
    int level,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => GameBoard(
              gridSizeRow: rows,
              gridSizeCol: cols,
              initialTime: initialTime,
              level: level,
              levelName: levelName,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Selecciona Nivel'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            levelButton(context, 'Fácil', 4, 3, 30, 1),
            levelButton(context, 'Medio', 6, 3, 25, 2),
            levelButton(context, 'Difícil', 6, 4, 20, 3),
            levelButton(context, 'Extremo', 6, 4, 15, 4),
          ],
        ),
      ),
    );
  }

  Widget levelButton(
    BuildContext context,
    String text,
    int rows,
    int cols,
    int time,
    int level,
  ) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed:
                () => navigateToGame(context, text, rows, cols, time, level),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              text,
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/game_stats_storage.dart';
import '../screens/menu.dart';

class EndGameScreen extends StatefulWidget {
  final int level;
  final String levelName;
  final int score;
  final IconData icon;
  final Color color;
  final int time;
  final int rows;
  final int cols;

  const EndGameScreen({
    super.key,
    required this.level,
    required this.levelName,
    required this.score,
    required this.icon,
    required this.color,
    required this.time,
    required this.rows,
    required this.cols,
  });

  @override
  State<EndGameScreen> createState() => _EndGameScreenState();
}

class _EndGameScreenState extends State<EndGameScreen> {
  int highScore = 0;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    int storedHighScore =
        await GameStatsStorage().getRecordForLevel(widget.level);
    setState(() => highScore = storedHighScore);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 36, 36, 36),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              children: [
                const SizedBox(height: 100),
                _buildTitle(),
                const SizedBox(height: 30),
                _buildStatCard("Puntuación", widget.score, Icons.bubble_chart,
                    Colors.greenAccent),
                const SizedBox(height: 16),
                _buildStatCard(
                    "Récord", highScore, Icons.workspace_premium, Colors.amber),
              ],
            ),
            Column(
              children: [
                _buildActionButton("Intentar de nuevo", () {
                  final levelData = {
                    'level': widget.level,
                    'name': widget.levelName,
                    'icon': widget.icon,
                    'color': widget.color,
                    'time': widget.time,
                    'rows': widget.rows,
                    'cols': widget.cols,
                  };

                  navigateToGame(context, levelData);
                }, Icons.replay, Colors.blue, isOutlined: true),
                const SizedBox(height: 16),
                _buildActionButton("Volver al menú", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MenuScreen()),
                  );
                }, Icons.widgets, Colors.white, isOutlined: true),
                const SizedBox(height: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: widget.color.withValues(alpha: 0.2),
          child: Icon(widget.icon, color: widget.color, size: 30),
        ),
        const SizedBox(height: 16),
        Text(
          "Nivel ${widget.levelName}",
          style: const TextStyle(
            fontSize: 34,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "Resumen de partida",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, int value, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 16),
          Text(
            "$label:",
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
            ),
          ),
          const Spacer(),
          Text(
            "$value",
            style: TextStyle(
              color: color,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      String text, VoidCallback onPressed, IconData icon, Color color,
      {bool isOutlined = false}) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: isOutlined ? color : Colors.white,
          backgroundColor: isOutlined ? Colors.transparent : color,
          side: BorderSide(color: color, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Text(
              text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../models/game_stats_storage.dart';
import '../screens/menu.dart';

class EndGameScreen extends StatefulWidget {
  final int level;
  final int rows;
  final int cols;
  final int time;
  final int minMoves;
  final int movimientos;

  const EndGameScreen({
    super.key,
    required this.level,
    required this.rows,
    required this.cols,
    required this.time,
    required this.minMoves,
    required this.movimientos,
  });

  @override
  State<EndGameScreen> createState() => _EndGameScreenState();
}

class _EndGameScreenState extends State<EndGameScreen> {
  int highScore = 0;
  late int estrellas;

  @override
  void initState() {
    super.initState();
    estrellas = calcularEstrellas(widget.movimientos, widget.minMoves);
    print('Nivel: ${widget.level}');
    print('minMoves recibido: ${widget.minMoves}');
    print('movimientos hechos: ${widget.movimientos}');
    _loadHighScore();
    _guardarEstrellas();
  }

  Future<void> _loadHighScore() async {
    int storedHighScore =
        await GameStatsStorage().getRecordForLevel(widget.level);
    setState(() => highScore = storedHighScore);
  }

  int calcularEstrellas(int movimientos, int minMoves) {
    //condicionado a
    //0 a 5 movimientos = 3 estrellas
    //6 a 8 movimientos = 2 estrellas
    //9 o mas movimientos = 1 estrella
    final diferencia = movimientos - minMoves;

    if (diferencia <= 0) return 3;
    if (diferencia <= 2) return 2;
    if (diferencia <= 4) return 1;
    return 0;
  }

  Future<void> _guardarEstrellas() async {
    final storage = GameStatsStorage();
    final estrellasPrevias = await storage.getStarsForLevel(widget.level);
    if (estrellas > estrellasPrevias) {
      await storage.saveStarsForLevel(widget.level, estrellas);
      print('⭐ Estrellas actualizadas: $estrellas');
    } else {
      print(
          '↪️ Estrellas previas ($estrellasPrevias) son mejores o iguales. No se actualiza.');
    }
  }

  // Nueva función auxiliar
  String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remainingSeconds = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remainingSeconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Resumen de partida'),
        elevation: 0,
      ),
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
                const SizedBox(height: 16),
                _starsCard(),
                const SizedBox(height: 16),
                _buildStatCard("Tiempo", formatTime(widget.time), Icons.timer,
                    Colors.blueAccent),
                const SizedBox(height: 16),
                _buildStatCard("Movimientos realizados", widget.movimientos,
                    Icons.touch_app, Colors.blueAccent),
                const SizedBox(height: 16),
              ],
            ),
            Column(
              children: [
                _buildActionButton("Intentar de nuevo", () {
                  final levelData = {
                    'level': widget.level,
                    'time': widget.time,
                    'rows': widget.rows,
                    'cols': widget.cols,
                    'minMoves': widget.minMoves,
                    'movimientos': 0,
                  };

                  navigateToGame(context, levelData);
                }, Icons.replay, Colors.blue, isOutlined: true),
                const SizedBox(height: 16),
                _buildActionButton("Volver al menú", () {
                  Navigator.pushReplacement(
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
        Text(
          "Nivel ${widget.level}",
          style: const TextStyle(
            fontSize: 40,
            color: Colors.teal,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _starsCard() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Icon(
          index < estrellas ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 40,
        );
      }),
    );
  }

  Widget _buildStatCard(
      String label, dynamic value, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[850],
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

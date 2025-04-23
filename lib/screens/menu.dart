import 'package:flutter/material.dart';
import '../widgets/game_board.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  // Datos de los niveles
  final List<Map<String, dynamic>> levels = const [
    {
      'name': 'Fácil',
      'rows': 4,
      'cols': 3,
      'time': 20,
      'level': 1,
      'color': Colors.green,
      'icon': Icons.accessible_forward,
    },
    {
      'name': 'Medio',
      'rows': 5,
      'cols': 4,
      'time': 30,
      'level': 2,
      'color': Colors.blue,
      'icon': Icons.directions_run,
    },
    {
      'name': 'Difícil',
      'rows': 6,
      'cols': 4,
      'time': 35,
      'level': 3,
      'color': Colors.orange,
      'icon': Icons.fitness_center,
    },
    {
      'name': 'Extremo',
      'rows': 6,
      'cols': 5,
      'time': 40,
      'level': 4,
      'color': Colors.red,
      'icon': Icons.whatshot,
    },
    {
      'name': 'Legendario',
      'rows': 6,
      'cols': 6,
      'time': 45,
      'level': 5,
      'color': Colors.purple,
      'icon': FontAwesomeIcons.skull,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Selecciona Nivel'),
        backgroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 30),
            Expanded(
              child: ListView.separated(
                itemCount: levels.length,
                separatorBuilder: (_, __) => const SizedBox(height: 15),
                itemBuilder: (context, index) {
                  final level = levels[index];
                  return _LevelCard(
                    level: level,
                    onPressed: () => navigateToGame(context, level),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final Map<String, dynamic> level;
  final VoidCallback onPressed;

  const _LevelCard({required this.level, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: level['color'].withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(level['icon'], color: level['color'], size: 30),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level['name'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Tablero: ${level['rows']}x${level['cols']} | '
                      'Tiempo: ${level['time']} seg',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void navigateToGame(BuildContext context, Map<String, dynamic> level) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => GameBoard(
        gridSizeRow: level['rows'],
        gridSizeCol: level['cols'],
        initialTime: level['time'],
        level: level['level'],
        levelName: level['name'],
        icon: level['icon'],
        color: level['color'],
        time: level['time'],
      ),
    ),
  );
}

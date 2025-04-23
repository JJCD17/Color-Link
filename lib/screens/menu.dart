import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/game_board.dart';
import '../models/game_stats_storage.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
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
      'rows': 8,
      'cols': 5,
      'time': 45,
      'level': 5,
      'color': Colors.purple,
      'icon': FontAwesomeIcons.skull,
    },
  ];

  Map<int, int> records = {};

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final storage = GameStatsStorage();
    final Map<int, int> loadedRecords = {};

    for (var level in levels) {
      int levelNumber = level['level'];
      int record = await storage.getRecordForLevel(levelNumber);
      loadedRecords[levelNumber] = record;
    }

    setState(() {
      records = loadedRecords;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Selecciona Nivel'),
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
                  final levelNumber = level['level'];
                  final record = records[levelNumber] ?? 0;

                  return _LevelCard(
                    level: level,
                    record: record,
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
  final int record;
  final VoidCallback onPressed;

  const _LevelCard({
    required this.level,
    required this.record,
    required this.onPressed,
  });

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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                // Nivel
                                level['name'],
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: level['color'],
                                ),
                              ),
                              Text(
                                // Record
                                '🏆 $record pts',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.amber,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(
                            //Detalles del nivel
                            'Tablero: ${level['rows']}x${level['cols']} | '
                            'Tiempo: ${level['time']} seg',
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[600]),
                          ),
                        ],
                      ),
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

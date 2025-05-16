import 'package:flutter/material.dart';
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
      'level': 1,
      'rows': 3,
      'cols': 3,
      'minMoves': 5,
      'movimientos': 0,
    },
    {
      'level': 2,
      'rows': 3,
      'cols': 3,
      'minMoves': 5,
      'movimientos': 0,
    },
    {
      'level': 3,
      'rows': 3,
      'cols': 3,
      'minMoves': 5,
      'movimientos': 0,
    },
    {
      'level': 4,
      'rows': 3,
      'cols': 3,
      'minMoves': 5,
      'movimientos': 0,
    },
    {
      'level': 5,
      'rows': 3,
      'cols': 3,
      'minMoves': 5,
      'movimientos': 0,
    },
    {
      'level': 6,
      'rows': 4,
      'cols': 4,
      'minMoves': 5,
      'movimientos': 0,
    },
    {
      'level': 7,
      'rows': 4,
      'cols': 4,
      'minMoves': 5,
      'movimientos': 0,
    },
    {
      'level': 8,
      'rows': 4,
      'cols': 4,
      'minMoves': 5,
      'movimientos': 0,
    },
    {
      'level': 9,
      'rows': 4,
      'cols': 5,
      'minMoves': 5,
      'movimientos': 0,
    },
    {
      'level': 10,
      'rows': 4,
      'cols': 5,
      'minMoves': 5,
      'movimientos': 0,
    },
  ];

  Map<int, int> records = {};
  Map<int, int> starsPerLevel = {};

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  Future<void> _loadRecords() async {
    final storage = GameStatsStorage();
    final Map<int, int> loadedRecords = {};
    final Map<int, int> loadedStars = {};

    for (var level in levels) {
      int levelNumber = level['level'];
      int record = await storage.getRecordForLevel(levelNumber);
      int stars = await storage.getStarsForLevel(levelNumber);
      loadedRecords[levelNumber] = record;
      loadedStars[levelNumber] = stars;
    }

    setState(() {
      records = loadedRecords; // records reales
      starsPerLevel = loadedStars; // estrellas reales
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
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemCount: levels.length,
          itemBuilder: (context, index) {
            final level = levels[index];
            final levelNumber = level['level'];

            // Suponiendo que usas el record como número de estrellas (0 a 3)
            final stars = (starsPerLevel[levelNumber] ?? 0).clamp(0, 3);

            return _LevelGridTile(
              level: level,
              stars: stars,
              onPressed: () => navigateToGame(context, level),
            );
          },
        ),
      ),
    );
  }
}

class _LevelGridTile extends StatelessWidget {
  final Map<String, dynamic> level;
  final int stars;
  final VoidCallback onPressed;

  const _LevelGridTile({
    required this.level,
    required this.stars,
    required this.onPressed,
  });

  List<Widget> _buildStars(int count) {
    return List.generate(3, (index) {
      return Icon(
        index < count ? Icons.star : Icons.star_border,
        color: index < count ? Colors.amber : Colors.grey,
        size: 20,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'Nivel ${level['level']}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: level['color'],
                ),
              ),
              if (level['level'] == 1)
                const Text(
                  'Tutorial',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: _buildStars(stars),
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
        level: level['level'],
        gridSizeRow: level['rows'],
        gridSizeCol: level['cols'],
        time: 0,
        minMoves: level['minMoves'],
        movimientos: level['movimientos'],
      ),
    ),
  );
}

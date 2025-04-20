import 'dart:async';

import 'package:flutter/material.dart';
import 'timer_widget.dart';
import '../models/point_data.dart';
import 'point_tile.dart';
import '../models/score_manager.dart';
import 'dart:math';

class GameBoard extends StatefulWidget {
  final int gridSizeRow;
  final int gridSizeCol;
  final int initialTime;
  final int level;
  final String levelName;

  const GameBoard({
    super.key,
    required this.gridSizeRow,
    required this.gridSizeCol,
    required this.initialTime,
    required this.level,
    required this.levelName,
  });

  @override
  State<GameBoard> createState() => GameBoardState();
}

class GameBoardState extends State<GameBoard> {
  bool gameStarted = false;
  final GlobalKey<TimerWidgetState> timerKey = GlobalKey<TimerWidgetState>();
  late ScoreManager scoreManager;
  late List<List<PointData>> grid;
  List<PointData> selectedPoints = [];
  final List<Color> availableColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
  ];

  @override
  void initState() {
    super.initState();
    scoreManager = ScoreManager();
    _generateGrid();
  }

  void _generateGrid() {
    final totalTiles = widget.gridSizeRow * widget.gridSizeCol;

    // Asegúrate que el número total de cuadros es par
    (totalTiles % 2 == 0, 'El número total de cuadros debe ser par');

    final random = Random();
    final List<Color> pairedColors = [];

    // Creamos pares hasta llenar el tablero
    while (pairedColors.length < totalTiles) {
      final color = availableColors[random.nextInt(availableColors.length)];
      pairedColors.add(color);
      pairedColors.add(color); // lo agregamos dos veces para crear los pares
    }

    // Mezclamos los colores
    pairedColors.shuffle();

    // Generamos el grid con los colores mezclados
    grid = List.generate(widget.gridSizeRow, (row) {
      return List.generate(widget.gridSizeCol, (col) {
        final index = row * widget.gridSizeCol + col;
        return PointData(
          row: row,
          col: col,
          color: pairedColors[index],
          isSelected: false,
          isVisible: true,
        );
      });
    });
  }

  void _handleTimeUp() {
    setState(() {
      gameStarted = false;
    });
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("¡Tiempo agotado!"),
            content: Text("Tu puntuación: ${scoreManager.score} puntos"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Aceptar"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.levelName),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 36, 36, 36),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 36, 36, 36),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final totalHeight = constraints.maxHeight;
          final totalWidth = constraints.maxWidth;

          final reservedHeight = 140.0;
          final availableHeight = totalHeight - reservedHeight;

          final cellWidth = totalWidth / widget.gridSizeCol;
          final cellHeight = availableHeight / widget.gridSizeRow;

          final cellSize = min(cellHeight, cellWidth);

          return Column(
            children: [
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TimerWidget(
                    //Timer
                    key: timerKey,
                    initialTime: widget.initialTime,
                    onTimeUp: _handleTimeUp,
                  ),
                  const SizedBox(width: 20),
                  Container(
                    //Sistema de puntos
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.yellow, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          '${scoreManager.score}',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              //Tablero
              Expanded(
                child:
                    !gameStarted
                        ? const Center(
                          child: Text(
                            'El tablero se genera al iniciar la partida',
                            style: TextStyle(
                              fontSize: 16.0,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        )
                        : Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(widget.gridSizeRow, (row) {
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: List.generate(widget.gridSizeCol, (
                                  col,
                                ) {
                                  return SizedBox(
                                    width: cellSize,
                                    height: cellSize,
                                    child: GestureDetector(
                                      onTap: () {
                                        final tappedPoint = grid[row][col];
                                        if (tappedPoint.isSelected) {
                                          setState(() {
                                            tappedPoint.isSelected = false;
                                            selectedPoints.remove(tappedPoint);
                                          });
                                          return;
                                        }

                                        if (selectedPoints.length < 2) {
                                          setState(() {
                                            tappedPoint.isSelected = true;
                                            selectedPoints.add(tappedPoint);
                                          });

                                          if (selectedPoints.length == 2) {
                                            final p1 = selectedPoints[0];
                                            final p2 = selectedPoints[1];

                                            if (p1 != p2 &&
                                                p1.color == p2.color) {
                                              //Se encontro par
                                              scoreManager.addPoints(
                                                level: widget.level,
                                              );
                                              Future.delayed(
                                                const Duration(
                                                  milliseconds: 150,
                                                ),
                                                () {
                                                  setState(() {
                                                    for (var point
                                                        in selectedPoints) {
                                                      point.isVisible = false;
                                                    }
                                                  });

                                                  Future.delayed(
                                                    const Duration(
                                                      milliseconds: 200,
                                                    ),
                                                    () {
                                                      setState(() {
                                                        selectedPoints.clear();

                                                        final anyVisible = grid
                                                            .any(
                                                              (row) => row.any(
                                                                (point) =>
                                                                    point
                                                                        .isVisible,
                                                              ),
                                                            );

                                                        if (!anyVisible) {
                                                          _generateGrid();
                                                          timerKey.currentState
                                                              ?.addTime();
                                                        }
                                                      });
                                                    },
                                                  );
                                                },
                                              );
                                            } else {
                                              //Fallo al encontrar el par
                                              scoreManager.subtractPoints(
                                                widget.level,
                                              );
                                              Future.delayed(
                                                const Duration(
                                                  milliseconds: 150,
                                                ),
                                                () {
                                                  setState(() {
                                                    for (var point
                                                        in selectedPoints) {
                                                      point.isSelected = false;
                                                    }
                                                    selectedPoints.clear();
                                                    timerKey.currentState
                                                        ?.subtractTime(2);
                                                  });
                                                },
                                              );
                                            }
                                          }
                                        }
                                      },
                                      child: PointTile(
                                        color: grid[row][col].color,
                                        isSelected: grid[row][col].isSelected,
                                        isVisible: grid[row][col].isVisible,
                                        gameStarted: gameStarted,
                                      ),
                                    ),
                                  );
                                }),
                              );
                            }),
                          ),
                        ),
              ),

              const SizedBox(height: 10),
              if (!gameStarted)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      gameStarted = true;
                      selectedPoints.clear();
                      _generateGrid();
                      scoreManager.reset();
                    });
                    timerKey.currentState?.startTimer();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Iniciar partida',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              const SizedBox(height: 10),
            ],
          );
        },
      ),
    );
  }
}

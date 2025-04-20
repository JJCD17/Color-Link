import 'dart:async';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

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

    // Inicia automáticamente después de 3 segundos
    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        setState(() => gameStarted = true);
        timerKey.currentState?.startTimer();
      }
    });
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
        backgroundColor: Colors.black,

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

              //Tablero
              Expanded(
                child:
                    !gameStarted
                        ? LayoutBuilder(
                          builder: (context, constraints) {
                            // Calculamos el tamaño máximo disponible
                            final maxWidth =
                                constraints.maxWidth -
                                40; // Restamos los márgenes
                            final maxHeight = constraints.maxHeight - 40;

                            // Calculamos el tamaño de celda basado en la proporción real
                            final cellWidth = maxWidth / widget.gridSizeCol;
                            final cellHeight = maxHeight / widget.gridSizeRow;
                            final cellSize = min(cellWidth, cellHeight);
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                // Tablero vacío
                                GridView.count(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  crossAxisCount: widget.gridSizeCol,
                                  children: List.generate(
                                    widget.gridSizeRow * widget.gridSizeCol,
                                    (index) => Container(
                                      margin: EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.grey.withOpacity(0.3),
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),

                                // Countdown timer
                                CircularCountDownTimer(
                                  duration: 5,
                                  width: 120,
                                  height: 120,
                                  ringColor: Colors.grey[800]!,
                                  fillColor: Colors.blueAccent,
                                  backgroundColor: Colors.black.withOpacity(
                                    0.7,
                                  ),
                                  strokeWidth: 8,
                                  textStyle: TextStyle(
                                    fontSize: 30,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  isReverse: true,
                                  onComplete: () {
                                    setState(() => gameStarted = true);
                                    timerKey.currentState?.startTimer();
                                  },
                                ),
                              ],
                            );
                          },
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
            ],
          );
        },
      ),
    );
  }
}

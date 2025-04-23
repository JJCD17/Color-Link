import 'dart:async';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';

import 'package:flutter/material.dart';
import 'timer_widget.dart';
import '../models/point_data.dart';
import 'point_tile.dart';
import '../models/score_manager.dart';
import 'dart:math';
import '../models/game_stats_storage.dart';
import '../screens/end_game.dart';

class GameBoard extends StatefulWidget {
  final int gridSizeRow;
  final int gridSizeCol;
  final int initialTime;
  final int level;
  final String levelName;
  final IconData icon;
  final Color color;
  final int time;

  const GameBoard({
    super.key,
    required this.gridSizeRow,
    required this.gridSizeCol,
    required this.initialTime,
    required this.level,
    required this.levelName,
    required this.icon,
    required this.color,
    required this.time,
  });

  @override
  State<GameBoard> createState() => GameBoardState();
}

class GameBoardState extends State<GameBoard> {
  bool gameStarted = false;
  bool isCountdownActive = true;
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
    // Actualiza la variable que indica el estado del juego
    setState(() {
      gameStarted = false;
    });

    // Guardar la puntuación y el récord si aplica
    GameStatsStorage().saveScoreForLevel(widget.level, scoreManager.score);

    GameStatsStorage().saveLastLevelPlayed(widget.level);

    // Navegar a la pantalla de fin de juego
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EndGameScreen(
            level: widget.level,
            levelName: widget.levelName,
            score: scoreManager.score,
            icon: widget.icon,
            color: widget.color,
            time: widget.time,
            rows: widget.gridSizeRow,
            cols: widget.gridSizeCol,
          ),
        ),
      );
    }
  }

  void _showExitConfirmation(BuildContext context) {
    timerKey.currentState?.pauseTimer();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber, color: Colors.orange),
              SizedBox(width: 10),
              Text('Partida en progreso'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tienes una partida en curso.'),
              SizedBox(height: 8),
              Text('Si sales ahora:'),
              SizedBox(height: 4),
              Text('• Perderás el progreso actual',
                  style: TextStyle(color: Colors.red)),
              SizedBox(height: 4),
              Text('• No se guardará tu puntuación',
                  style: TextStyle(color: Colors.red)),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Continuar jugando'),
              onPressed: () {
                Navigator.of(context).pop();
                // Reanudar el timer al continuar
                timerKey.currentState?.resumeTimer();
              },
            ),
            TextButton(
              child: const Text('Salir de todas formas',
                  style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
                Navigator.of(context).pop(true); // Sale del GameBoard
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop:
          !isCountdownActive, // Solo permite pop cuando no hay countdown activo
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (!didPop && !isCountdownActive) {
          _showExitConfirmation(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: isCountdownActive
              ? IconButton(
                  icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
                  onPressed: null,
                  tooltip: 'Espera a que comience la partida',
                )
              : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => _showExitConfirmation(context),
                ),
          title: Text(
            widget.levelName,
          ),
          centerTitle: true,
          titleTextStyle: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: widget.color,
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
                const SizedBox(height: 30),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 150,
                        child: TimerWidget(
                          key: timerKey,
                          initialTime: widget.initialTime,
                          onTimeUp: _handleTimeUp,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Container(
                        //Score
                        width: 150, // Ancho fijo
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.yellow.withValues(),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star,
                                color: Colors.white, size: 24),
                            const SizedBox(width: 10),
                            SizedBox(
                              width: 60,
                              child: Text(
                                '${scoreManager.score}'
                                    .toString()
                                    .padLeft(3, '0'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                //Tablero
                Expanded(
                  child: !gameStarted
                      ? LayoutBuilder(
                          builder: (context, constraints) {
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
                                          color: Colors.grey[800]!,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                  ),
                                ),

                                // Countdown timer
                                CircularCountDownTimer(
                                  duration: 5,
                                  width: 150,
                                  height: 150,
                                  ringColor: Colors.grey[800]!,
                                  fillColor: Colors.blueAccent,
                                  backgroundColor: Colors.black38,
                                  strokeWidth: 8,
                                  textStyle: TextStyle(
                                    fontSize: 50,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  isReverse: true,
                                  onComplete: () {
                                    setState(() {
                                      gameStarted = true;
                                      isCountdownActive =
                                          false; // Countdown terminó
                                    });
                                    timerKey.currentState?.startTimer();
                                  },
                                ),
                              ],
                            );
                          },
                        )
                      : // Tablero
                      Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(widget.gridSizeRow, (row) {
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children:
                                    List.generate(widget.gridSizeCol, (col) {
                                  return SizedBox(
                                    width: cellSize,
                                    height: cellSize,
                                    child: GestureDetector(
                                      onTap: () {
                                        final tappedPoint = grid[row][col];

                                        // Si el punto ya estaba seleccionado, se deselecciona
                                        if (tappedPoint.isSelected) {
                                          setState(() {
                                            tappedPoint.isSelected = false;
                                            selectedPoints.remove(tappedPoint);
                                          });
                                          return;
                                        }

                                        // Solo se pueden seleccionar un máximo de 2 puntos a la vez
                                        if (selectedPoints.length < 2) {
                                          setState(() {
                                            tappedPoint.isSelected = true;
                                            selectedPoints.add(tappedPoint);
                                          });

                                          // Cuando hay 2 puntos seleccionados, se evalúan
                                          if (selectedPoints.length == 2) {
                                            final p1 = selectedPoints[0];
                                            final p2 = selectedPoints[1];

                                            // Si los puntos son distintos y del mismo color
                                            if (p1 != p2 &&
                                                p1.color == p2.color) {
                                              // Se encontró un par válido
                                              scoreManager.addPoints(
                                                  level: widget.level);

                                              // Pequeña espera antes de ocultar los puntos encontrados
                                              Future.delayed(
                                                  const Duration(
                                                      milliseconds: 100), () {
                                                setState(() {
                                                  for (var point
                                                      in selectedPoints) {
                                                    point.isVisible = false;
                                                  }
                                                });

                                                // Pequeña espera adicional para limpiar selección
                                                Future.delayed(
                                                    const Duration(
                                                        milliseconds: 150), () {
                                                  setState(() {
                                                    selectedPoints.clear();

                                                    // Verifica si aún quedan puntos visibles
                                                    final anyVisible = grid.any(
                                                        (row) => row.any(
                                                            (point) => point
                                                                .isVisible));

                                                    if (!anyVisible) {
                                                      // Si no quedan puntos, se genera nuevo tablero y se agrega tiempo
                                                      _generateGrid();
                                                      timerKey.currentState
                                                          ?.addTimeByLevel(
                                                              widget.level);
                                                    }
                                                  });
                                                });
                                              });
                                            } else {
                                              // No son del mismo color o es el mismo punto
                                              scoreManager
                                                  .subtractPoints(widget.level);

                                              // Pequeña espera antes de deseleccionar y penalizar
                                              Future.delayed(
                                                  const Duration(
                                                      milliseconds: 150), () {
                                                setState(() {
                                                  for (var point
                                                      in selectedPoints) {
                                                    point.isSelected = false;
                                                  }
                                                  selectedPoints.clear();
                                                  // Penalización de tiempo por error
                                                  timerKey.currentState
                                                      ?.subtractTime(2);
                                                });
                                              });
                                            }
                                          }
                                        }
                                      },

                                      // Widget que representa visualmente cada punto
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
      ),
    );
  }
}

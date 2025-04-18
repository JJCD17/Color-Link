import 'dart:async';

import 'package:flutter/material.dart';
import 'timer_widget.dart';
import '../models/point_data.dart';
import 'point_tile.dart';
import 'dart:math';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => GameBoardState();
}

class GameBoardState extends State<GameBoard> {
  bool gameStarted = false;
  final GlobalKey<TimerWidgetState> timerKey = GlobalKey<TimerWidgetState>();
  final int gridSizeRow = 8;
  final int gridSizeCol = 4;
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
    _generateGrid();
  }

  void _generateGrid() {
    final totalTiles = gridSizeRow * gridSizeCol;

    // Asegúrate que el número total de cuadros es par
    assert(totalTiles % 2 == 0, 'El número total de cuadros debe ser par');

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
    grid = List.generate(gridSizeRow, (row) {
      return List.generate(gridSizeCol, (col) {
        final index = row * gridSizeCol + col;
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalHeight = constraints.maxHeight;
        final totalWidth = constraints.maxWidth;

        // Altura estimada para temporizador + botón
        final reservedHeight = 140.0;

        // Área disponible para el grid
        final availableHeight = totalHeight - reservedHeight;

        // Tamaño de celda cuadrada
        final cellSize = min(
          availableHeight / gridSizeRow,
          totalWidth / gridSizeCol,
        );

        return Column(
          children: [
            const SizedBox(height: 10),

            // Temporizador
            TimerWidget(
              key: timerKey,
              initialTime: 20,
              onTimeUp: _handleTimeUp,
            ),
            const SizedBox(height: 10),

            // Tablero
            Expanded(
              child:
                  !gameStarted
                      ? Center(
                        child: Text(
                          'El tablero se genera al iniciar la partida',
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      )
                      : SizedBox(
                        height: cellSize * gridSizeRow,
                        width: cellSize * gridSizeCol,
                        child: Column(
                          children: List.generate(gridSizeRow, (row) {
                            return Row(
                              children: List.generate(gridSizeCol, (col) {
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
                                          final sameColor =
                                              selectedPoints[0].color ==
                                              selectedPoints[1].color;

                                          if (sameColor) {
                                            Future.delayed(
                                              const Duration(milliseconds: 150),
                                              () {
                                                setState(() {
                                                  for (var point
                                                      in selectedPoints) {
                                                    point.isVisible = false;
                                                  }
                                                });

                                                // Esperar que la animación termine antes de limpiar
                                                Future.delayed(
                                                  const Duration(
                                                    milliseconds: 400,
                                                  ),
                                                  () {
                                                    setState(() {
                                                      selectedPoints.clear();

                                                      // Revisar si ya no queda ningún punto visible
                                                      final anyVisible = grid
                                                          .any(
                                                            (row) => row.any(
                                                              (point) =>
                                                                  point
                                                                      .isVisible,
                                                            ),
                                                          );

                                                      if (!anyVisible) {
                                                        _generateGrid(); // genera nuevos colores
                                                      }
                                                    });
                                                  },
                                                );
                                              },
                                            );
                                          } else {
                                            print('No coinciden');
                                            Future.delayed(
                                              const Duration(milliseconds: 350),
                                              () {
                                                setState(() {
                                                  for (var point
                                                      in selectedPoints) {
                                                    point.isSelected = false;
                                                  }
                                                  selectedPoints.clear();
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

            // Botón "Iniciar partida"
            if (!gameStarted)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    gameStarted = true;
                    selectedPoints.clear(); // limpia selecciones anteriores
                    _generateGrid(); // genera un nuevo tablero
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
    );
  }
}

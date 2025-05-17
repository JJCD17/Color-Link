import 'dart:async';
import 'package:circular_countdown_timer/circular_countdown_timer.dart';
import 'package:toastification/toastification.dart';

import 'package:flutter/material.dart';
import 'timer_widget.dart';
import '../models/point_data.dart';
import 'point_tile.dart';
import 'dart:math';
import '../screens/end_game.dart';

//Niveles
import '../levels/generateSimpleGrid.dart';

class GameBoard extends StatefulWidget {
  final int level;
  final int gridSizeRow;
  final int gridSizeCol;
  final int time;
  final int minMoves;
  final int movimientos;

  const GameBoard({
    super.key,
    required this.level,
    required this.gridSizeRow,
    required this.gridSizeCol,
    required this.time,
    required this.minMoves,
    required this.movimientos,
  });

  @override
  State<GameBoard> createState() => GameBoardState();
}

class GameBoardState extends State<GameBoard> {
  bool gameStarted = false; // Controla si el juego ha comenzado
  bool isCountdownActive = true; // Controla si el countdown esta activo
  final GlobalKey<TimerWidgetState> timerKey =
      GlobalKey<TimerWidgetState>(); // Clave global para acceder al TimerWidget

  late List<List<PointData>> grid;
  late List<List<PointData>> referenceGrid;
  late int maxAllowedMoves;
  late int movimientosTotales;

  List<PointData> selectedPoints = [];
  // Guarda los movimientos realizados en una lista para que el jugador pueda revertirlos
  final List<Point> performedMoves = [];

  final List<Color> availableColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.white,
    Colors.grey,
    Colors.yellow,
    Colors.tealAccent,
    Colors.pink,
    Colors.brown,
    Colors.cyan,
    Colors.indigo,
    Colors.amber,
    Colors.teal,
    Colors.limeAccent
  ];

  @override
  void initState() {
    super.initState();
    maxAllowedMoves = widget.minMoves;
    movimientosTotales = widget.movimientos;

    // Paso 1: Genera la referencia final del puzzle
    referenceGrid = _generateReferenceGridForLevel(
      widget.level,
      widget.gridSizeRow,
      widget.gridSizeCol,
    );

    // Paso 2: Crea una copia para mezclarla
    grid = List.generate(widget.gridSizeRow, (row) {
      return List.generate(widget.gridSizeCol, (col) {
        return PointData(
          row: row,
          col: col,
          color: referenceGrid[row][col].color,
          isSelected: false,
          isVisible: true,
        );
      });
    });

    // Paso 3: Mezcla el grid que usará el jugador (NO el de referencia)
    _shuffleGrid(grid, widget.minMoves);

    // Inicia automáticamente después de 5 segundos
    Future.delayed(Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          gameStarted = true;
          isCountdownActive = false;
        });
        timerKey.currentState?.startTimer();
      }
    });

    _debugNullCount();
  }

  PointData _findEmptyCell() {
    for (int row = 0; row < widget.gridSizeRow; row++) {
      for (int col = 0; col < widget.gridSizeCol; col++) {
        if (grid[row][col].color == null) {
          return grid[row][col];
        }
      }
    }
    throw Exception('No empty cell found!');
  }

  bool _isAdjacent(int row, int col, PointData emptyCell) {
    return (row == emptyCell.row &&
            (col == emptyCell.col - 1 || col == emptyCell.col + 1)) ||
        (col == emptyCell.col &&
            (row == emptyCell.row - 1 || row == emptyCell.row + 1));
  }

  List<List<PointData>> _generateReferenceGridForLevel(
      int level, int rows, int cols) {
    // Puedes usar un switch o ifs para definir niveles
    switch (level) {
      case 1:
        return generateSimpleGrid(
            rows: rows, cols: cols, availableColors: availableColors);
      default:
        return generateSimpleGrid(
            rows: rows, cols: cols, availableColors: availableColors);
    }
  }

  void _shuffleGrid(List<List<PointData>> grid, int moves) {
    int nullRow = widget.gridSizeRow - 1;
    int nullCol = widget.gridSizeCol - 1;

    // ⚠️ ESTO ES CLAVE: inicializa el `null` correctamente
    grid[nullRow][nullCol].color = null;

    final random = Random();

    for (int i = 0; i < moves; i++) {
      final directions = [
        Point(-1, 0), // Arriba
        Point(1, 0), // Abajo
        Point(0, -1), // Izquierda
        Point(0, 1), // Derecha
      ];

      final validDirections = directions.where((dir) {
        final newRow = nullRow + dir.x;
        final newCol = nullCol + dir.y;
        return newRow >= 0 &&
            newRow < widget.gridSizeRow &&
            newCol >= 0 &&
            newCol < widget.gridSizeCol;
      }).toList();

      if (validDirections.isEmpty) break;

      final dir = validDirections[random.nextInt(validDirections.length)];
      final newRow = nullRow + dir.x;
      final newCol = nullCol + dir.y;

      // Intercambio correcto
      grid[nullRow][nullCol].color = grid[newRow][newCol].color;
      grid[newRow][newCol].color = null;

      nullRow = newRow;
      nullCol = newCol;
    }
  }

  // Función de debug para verificar `null`s
  void _debugNullCount() {
    int count = 0;
    for (int row = 0; row < grid.length; row++) {
      for (int col = 0; col < grid[row].length; col++) {
        if (grid[row][col].color == null) {
          print('Null encontrado en: ($row, $col)');
          count++;
        }
      }
    }
    print('Total de nulls en grid: $count'); // Debe ser exactamente 1
  }

  void _handleWin() {
    timerKey.currentState?.pauseTimer();

    // Muestra el toast y luego navega
    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      autoCloseDuration: const Duration(seconds: 3),
      title: Text(
        '¡Felicidades!',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      description: Text(
        'Nivel completado con éxito',
        style: TextStyle(color: Colors.white70),
      ),
      alignment: Alignment.bottomCenter,
      icon: const Icon(Icons.celebration, color: Colors.white),
      primaryColor: Colors.green[700],
      backgroundColor: Colors.green[800],
      borderRadius: BorderRadius.circular(12),
      showProgressBar: true,
      callbacks: ToastificationCallbacks(
        onCloseButtonTap: (_) => _navigateToEndGame(),
      ),
    );

    // Programa la navegación para después que se cierre el toast
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _navigateToEndGame();
      }
    });
  }

  void _navigateToEndGame() {
    int elapsedTime = timerKey.currentState?.currentTime ?? 0;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => EndGameScreen(
          level: widget.level,
          rows: widget.gridSizeRow,
          cols: widget.gridSizeCol,
          time: elapsedTime,
          minMoves: widget.minMoves,
          movimientos: movimientosTotales,
        ),
      ),
    );
  }

  bool areGridsEqual() {
    for (int row = 0; row < widget.gridSizeRow; row++) {
      for (int col = 0; col < widget.gridSizeCol; col++) {
        if (grid[row][col].color != referenceGrid[row][col].color) {
          return false;
        }
      }
    }
    return true;
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
            'Nivel ${widget.level}',
          ),
          centerTitle: true,
        ),
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
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 165,
                        height: 100,
                        child: TimerWidget(
                          key: timerKey,
                          onTimeUp: _navigateToEndGame,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Container(
                        width: 180,
                        height: 100,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.yellow.withOpacity(0.5),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Movimientos',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Max: $maxAllowedMoves Tot: $movimientosTotales',
                              style: TextStyle(
                                color: Colors.yellow,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                //Tablero de refenrencia
                SizedBox(
                  width: widget.gridSizeCol * 40,
                  height: widget.gridSizeRow * 40,
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: widget.gridSizeCol,
                    ),
                    itemCount: widget.gridSizeRow * widget.gridSizeCol,
                    itemBuilder: (context, index) {
                      final row = index ~/ widget.gridSizeCol;
                      final col = index % widget.gridSizeCol;
                      return Container(
                        margin: EdgeInsets.all(1),
                        decoration: BoxDecoration(
                          color: referenceGrid[row][col].color,
                          border: Border.all(color: Colors.grey[800]!),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
                if (widget.level == 1)
                  Text(
                    'Haz clic en las casillas para moverlas al espacio vacío hasta completar el patrón del tablero de referencia. Tienes un máximo de movimientos para obtener 3 estrellas y tiempo que muestra cuánto tardaste en completar el nivel.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                SizedBox(height: 20),
                //Game board
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
                                  backgroundColor:
                                      const Color.fromARGB(54, 0, 0, 0),
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
                      : // Tablero jugable
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

                                        // Si la celda seleccionada es la vacía, no hacemos nada
                                        if (tappedPoint.color == null) return;

                                        // Verificar si la celda seleccionada es adyacente a la vacía
                                        final emptyCell = _findEmptyCell();
                                        if (_isAdjacent(row, col, emptyCell)) {
                                          setState(() {
                                            // Mover la pieza hacia la vacía
                                            grid[emptyCell.row][emptyCell.col]
                                                .color = tappedPoint.color;
                                            grid[row][col].color = null;
                                            movimientosTotales++;
                                          });
                                        }
                                        // Verifica si ganó
                                        if (areGridsEqual()) {
                                          _handleWin();
                                        }
                                      },
                                      // Widget que representa visualmente cada punto
                                      child: PointTile(
                                        color: grid[row][col].color ??
                                            Colors
                                                .transparent, // Si es vacío, mostramos transparente
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

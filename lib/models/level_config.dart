/// Configuración de un nivel del juego.
///
/// Reemplaza los antiguos `Map<String, dynamic>` para evitar errores por
/// claves mal escritas y tener tipado estático.
class LevelConfig {
  final int level;
  final int rows;
  final int cols;
  final int minMoves;

  /// Movimientos realizados con los que se inicia el nivel (normalmente 0).
  final int movimientos;

  const LevelConfig({
    required this.level,
    required this.rows,
    required this.cols,
    required this.minMoves,
    this.movimientos = 0,
  });

  /// Crea una copia del nivel reiniciando los movimientos realizados.
  LevelConfig resetProgress() => LevelConfig(
        level: level,
        rows: rows,
        cols: cols,
        minMoves: minMoves,
        movimientos: 0,
      );
}

import 'package:shared_preferences/shared_preferences.dart';

class GameStatsStorage {
  /// Guarda el último nivel jugado
  Future<void> saveLastLevelPlayed(int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_level_played', level);
  }

  /// Devuelve el último nivel jugado
  Future<int?> getLastLevelPlayed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('last_level_played');
  }

  Future<void> saveTimeForLevel(int level, int time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('time_level_$level', time);
  }

  Future<int?> getTimeForLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('time_level_$level');
  }

  /// Guarda la puntuación actual del nivel y actualiza el récord si es mayor
  Future<void> saveScoreForLevel(int level, int score) async {
    final prefs = await SharedPreferences.getInstance();

    // Guardar la última puntuación de este nivel
    await prefs.setInt('last_score_level_$level', score);

    // Revisar y actualizar el récord si es necesario
    final recordKey = 'record_level_$level';
    final currentRecord = prefs.getInt(recordKey) ?? 0;
    if (score > currentRecord) {
      await prefs.setInt(recordKey, score);
    }
  }

  /// Devuelve la puntuación más alta registrada en un nivel
  Future<int> getRecordForLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('record_level_$level') ?? 0;
  }

  /// Devuelve la última puntuación registrada de un nivel
  Future<int> getLastScoreForLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('last_score_level_$level') ?? 0;
  }

  /// Borra todos los datos guardados (por si necesitas un reset)
  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Guarda la cantidad de estrellas ganadas en un nivel
  Future<void> saveStarsForLevel(int level, int stars) async {
    final prefs = await SharedPreferences.getInstance();
    // Opcional: guardar solo si es mejor que el anterior
    final currentStars = prefs.getInt('stars_level_$level') ?? 0;
    if (stars > currentStars) {
      await prefs.setInt('stars_level_$level', stars);
    }
  }

  /// Devuelve la cantidad de estrellas guardadas para un nivel
  Future<int> getStarsForLevel(int level) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('stars_level_$level') ?? 0;
  }
}

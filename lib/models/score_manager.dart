class ScoreManager {
  int score = 0;

  void reset() {
    score = 0;
  }

  void addPoints({required int level}) {
    switch (level) {
      case 1: //Facil
        score += 10;
        break;
      case 2: //Medio
        score += 15;
        break;
      case 3: //Dificil
        score += 20;
        break;
      case 4: //Extremo
        score += 22;
        break;
      default:
        score += 0;
        break;
    }
  }

  void subtractPoints(int level) {
    switch (level) {
      case 1:
        score -= 5;
        break;
      case 2:
        score -= 7;
        break;
      case 3:
        score -= 10;
        break;
      case 4:
        score -= 11;
        break;
      default:
        score -= 0;
    }
  }
}

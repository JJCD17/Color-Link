import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

class TimerWidget extends StatefulWidget {
  final int initialTime;
  final VoidCallback onTimeUp;
  final Color? warningColor;

  const TimerWidget({
    super.key,
    required this.initialTime,
    required this.onTimeUp,
    this.warningColor = Colors.orange,
  });

  @override
  TimerWidgetState createState() => TimerWidgetState();
}

class TimerWidgetState extends State<TimerWidget> {
  late int currentTime;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    currentTime = widget.initialTime;
  }

  //funcion que inicia el timer
  void startTimer() {
    timer?.cancel(); // Cancela el timer anterior si existe
    currentTime = widget.initialTime; // Reinicia el tiempo
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (currentTime > 0) {
        setState(() => currentTime--);
      } else {
        timer.cancel();
        widget.onTimeUp();
      }
    });
  }

  //funcion que suma segundos al tiempo actual
  void addTimeByLevel(int level) {
    int extraTime;

    switch (level) {
      case 1: // Fácil
        extraTime = 12;
        break;
      case 2: // Medio
        extraTime = 10;
        break;
      case 3: // Difícil
        extraTime = 8;
        break;
      case 4: // Extremo
        extraTime = 6;
        break;
      case 5: // Legendario
        extraTime = 4;
        break;
      default:
        extraTime = 15;
    }

    setState(() => currentTime += extraTime);
  }

  //funcion que resta 2 segundos al tiempo actual
  void subtractTime(int seconds) {
    setState(() {
      currentTime = max(0, currentTime - seconds);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isWarning = currentTime <= 5;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer, color: Colors.white, size: 24),
          const SizedBox(width: 8),
          SizedBox(
            width: 40,
            child: Text(
              '$currentTime'.toString().padLeft(2, '0'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isWarning ? widget.warningColor : Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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

  //funcion que suma 20 segundos al tiempo actual
  void addTime() {
    setState(() => currentTime += 20);
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black54,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer, color: Colors.white, size: 24),
          const SizedBox(width: 8),
          Text(
            '$currentTime',
            style: TextStyle(
              color: isWarning ? widget.warningColor : Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

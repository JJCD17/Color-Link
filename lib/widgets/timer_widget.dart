import 'package:flutter/material.dart';
import '../utils/timer_formatter.dart';
import 'dart:async';
import 'dart:math';

class TimerWidget extends StatefulWidget {
  final int initialTime;
  final VoidCallback onTimeUp;
  final bool countUp;

  const TimerWidget({
    super.key,
    required this.onTimeUp,
    this.initialTime = 0,
    this.countUp = true,
  });

  @override
  TimerWidgetState createState() => TimerWidgetState();
}

class TimerWidgetState extends State<TimerWidget> {
  late int _currentTime; // renombrado para evitar conflicto
  bool isFinished = false;
  bool isPaused = false;
  Timer? timer;
  DateTime? startTime;

  @override
  void initState() {
    super.initState();
    _currentTime = widget.initialTime;
    startTime = DateTime.now();
  }

  void _startPeriodicTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!isPaused) {
        setState(() {
          if (widget.countUp) {
            _currentTime++;
          } else {
            _currentTime--;
            if (_currentTime <= 0) {
              _currentTime = 0;
              widget.onTimeUp();
              timer?.cancel();
            }
          }
        });
      }
    });
  }

  void startTimer() {
    isPaused = false;
    timer?.cancel();
    startTime = DateTime.now();
    _startPeriodicTimer();
  }

  void resumeTimer() {
    if (!isPaused) return;
    isPaused = false;
    _startPeriodicTimer();
  }

  void pauseTimer() {
    setState(() {
      isPaused = true;
    });
    timer?.cancel();
  }

  void addTimeByLevel(int level) {
    int extraTime;
    switch (level) {
      case 1:
        extraTime = 12;
        break;
      case 2:
        extraTime = 10;
        break;
      case 3:
        extraTime = 8;
        break;
      case 4:
        extraTime = 6;
        break;
      case 5:
        extraTime = 4;
        break;
      default:
        extraTime = 15;
    }
    setState(() => _currentTime += extraTime);
  }

  void subtractTime(int seconds) {
    setState(() {
      isFinished = true;
      _currentTime = max(0, _currentTime - seconds);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  int getElapsedTime() => _currentTime;
  int get currentTime => _currentTime;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.black87, Colors.grey.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.cyanAccent.withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Icons.timer_outlined,
            color: Colors.cyanAccent.shade100,
            size: 26,
          ),
          const SizedBox(width: 12),
          Text(
            formatTime(_currentTime),
            style: const TextStyle(
              fontFamily: 'Courier',
              fontSize: 18,
              color: Colors.cyanAccent,
              letterSpacing: 2.5,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  blurRadius: 4,
                  color: Colors.cyanAccent,
                  offset: Offset(0, 0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class PointTile extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final bool isVisible;
  final bool gameStarted;

  const PointTile({
    super.key,
    required this.color,
    this.isSelected = false,
    this.isVisible = true,
    required this.gameStarted,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: isVisible && gameStarted ? 1.0 : 0.0,
      child: Container(
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.black,
            width: isSelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
      ),
    );
  }
}

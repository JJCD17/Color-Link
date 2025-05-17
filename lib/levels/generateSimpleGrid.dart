import 'dart:math';
import 'package:flutter/material.dart';
import '../models/point_data.dart';

List<List<PointData>> generateSimpleGrid({
  required int rows,
  required int cols,
  required List<Color> availableColors,
}) {
  final random = Random();
  final totalTiles = rows * cols;
  final List<Color?> colors = [];

  while (colors.length < totalTiles - 1) {
    final color = availableColors[random.nextInt(availableColors.length)];
    if (!colors.contains(color)) colors.add(color);
  }

  colors.add(null); // celda vacía

  return List.generate(rows, (row) {
    return List.generate(cols, (col) {
      final index = row * cols + col;
      return PointData(
        row: row,
        col: col,
        color: colors[index],
        isSelected: false,
        isVisible: true,
      );
    });
  });
}

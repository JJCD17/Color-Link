import 'package:flutter/material.dart';

class PointData {
  final int row;
  final int col;
  Color? color;
  final bool isEmpty;
  bool isSelected;
  bool isVisible;

  PointData({
    required this.row,
    required this.col,
    required this.color,
    this.isEmpty = false,
    this.isSelected = false,
    this.isVisible = true,
  });

  // Método factory para crear una celda vacía
  factory PointData.empty({int row = -1, int col = -1}) {
    return PointData(
      row: row,
      col: col,
      color: null,
      isEmpty: true,
    );
  }
}

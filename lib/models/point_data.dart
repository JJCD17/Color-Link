import 'package:flutter/material.dart';

class PointData {
  final int row;
  final int col;
  Color? color;
  bool isSelected;
  bool isVisible;

  PointData({
    required this.row,
    required this.col,
    required this.color,
    this.isSelected = false,
    this.isVisible = true,
  });
}

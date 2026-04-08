import 'package:flutter/material.dart';

extension HexColor on String {
  Color toColor() {
    final String normalized = replaceAll('#', '');
    final String buffer = normalized.length == 6 ? 'FF$normalized' : normalized;
    return Color(int.parse(buffer, radix: 16));
  }
}

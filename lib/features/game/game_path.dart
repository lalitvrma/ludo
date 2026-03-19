import 'package:flutter/material.dart';

class GamePath {
  static final List<Offset> _mainPath = [
    // Path starting from just after green's home
    Offset(6, 1), Offset(6, 2), Offset(6, 3), Offset(6, 4), Offset(6, 5),
    Offset(5, 6), Offset(4, 6), Offset(3, 6), Offset(2, 6), Offset(1, 6), Offset(0, 6),
    Offset(0, 7), // Green corner
    Offset(0, 8), Offset(1, 8), Offset(2, 8), Offset(3, 8), Offset(4, 8), Offset(5, 8),
    Offset(6, 9), Offset(6, 10), Offset(6, 11), Offset(6, 12), Offset(6, 13), Offset(6, 14),
    Offset(7, 14), // Yellow corner
    Offset(8, 14), Offset(8, 13), Offset(8, 12), Offset(8, 11), Offset(8, 10), Offset(8, 9),
    Offset(9, 8), Offset(10, 8), Offset(11, 8), Offset(12, 8), Offset(13, 8), Offset(14, 8),
    Offset(14, 7), // Blue corner
    Offset(14, 6), Offset(13, 6), Offset(12, 6), Offset(11, 6), Offset(10, 6), Offset(9, 6),
    Offset(8, 5), Offset(8, 4), Offset(8, 3), Offset(8, 2), Offset(8, 1), Offset(8, 0),
    Offset(7, 0), // Red corner
  ];

  static final Map<String, List<Offset>> homePaths = {
    'red': List.generate(6, (i) => Offset(7, 1 + i.toDouble())),
    'green': List.generate(6, (i) => Offset(1 + i.toDouble(), 7)),
    'yellow': List.generate(6, (i) => Offset(7, 13 - i.toDouble())),
    'blue': List.generate(6, (i) => Offset(13 - i.toDouble(), 7)),
  };

  static final Map<String, int> _startIndices = {
    'green': 1,
    'yellow': 14,
    'blue': 27,
    'red': 40,
  };

  static Offset getOffsetForPosition(String color, int position, double boardSize, int tokenIndex) {
    final step = boardSize / 15;
    if (position < 0) { // In home base
      final double homeX, homeY;
      switch (color) {
        case 'green':
          homeX = 1.5; homeY = 1.5;
          break;
        case 'red':
          homeX = 10.5; homeY = 1.5;
          break;
        case 'blue':
          homeX = 1.5; homeY = 10.5;
          break;
        case 'yellow':
          homeX = 10.5; homeY = 10.5;
          break;
        default:
          homeX = 0; homeY = 0;
      }
      final tokenX = homeX + (tokenIndex % 2) * 2;
      final tokenY = homeY + (tokenIndex ~/ 2) * 2;
      return Offset(tokenX * step, tokenY * step);
    }

    if (position >= 52) { // Home run
      final homeRunStep = position - 52;
      if(homeRunStep >= homePaths[color]!.length) return const Offset(-100, -100); // Should not happen
      return homePaths[color]![homeRunStep] * step;
    }

    final startIndex = _startIndices[color]!;
    final pathIndex = (startIndex + position) % 52;
    return _mainPath[pathIndex] * step;
  }
}

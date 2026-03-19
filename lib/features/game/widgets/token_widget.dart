import 'package:flutter/material.dart';
import 'package:myapp/features/game/widgets/token_painter.dart';

class TokenWidget extends StatelessWidget {
  final Color color;
  final double size;
  final bool isSelectable;
  final VoidCallback? onTap;

  const TokenWidget({
    super.key,
    required this.color,
    required this.size,
    this.isSelectable = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: isSelectable
            ? BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.8),
                    blurRadius: 8.0,
                    spreadRadius: 2.0,
                  ),
                ],
              )
            : null,
        child: CustomPaint(
          painter: TokenPainter(color: color),
        ),
      ),
    );
  }
}

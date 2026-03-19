import 'package:flutter/material.dart';

class GameMessageWidget extends StatelessWidget {
  final String message;

  const GameMessageWidget({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: Colors.black.withOpacity(0.7),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16.0,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

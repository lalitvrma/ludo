import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class DiceWidget extends StatefulWidget {
  final int result;

  const DiceWidget({super.key, required this.result});

  @override
  State<DiceWidget> createState() => _DiceWidgetState();
}

class _DiceWidgetState extends State<DiceWidget> {
  int _displayNumber = 1;
  Timer? _rollTimer;

  @override
  void initState() {
    super.initState();
    _displayNumber = widget.result > 0 ? widget.result : 1;
  }

  @override
  void didUpdateWidget(covariant DiceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.result != oldWidget.result && widget.result > 0) {
      _startRolling();
    }
  }

  void _startRolling() {
    int rollCount = 0;
    _rollTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      rollCount++;
      setState(() {
        _displayNumber = Random().nextInt(6) + 1;
      });

      if (rollCount >= 10) { // Roll for 1 second
        _stopRolling();
      }
    });
  }

  void _stopRolling() {
    _rollTimer?.cancel();
    setState(() {
      _displayNumber = widget.result;
    });
  }

  @override
  void dispose() {
    _rollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textResult = widget.result > 0 ? '$_displayNumber' : '-';

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.black, width: 2.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5.0,
            spreadRadius: 1.0,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          textResult,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

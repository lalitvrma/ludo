import 'package:flutter/material.dart';
import 'package:myapp/features/game/game_path.dart';
import 'package:myapp/features/game/services/game_service.dart';
import 'package:myapp/features/game/widgets/ludo_board_painter.dart';
import 'package:myapp/features/game/widgets/token_widget.dart';

class LudoBoard extends StatelessWidget {
  final Map<dynamic, dynamic> gameData;
  final String currentUserId;
  final Function(int) onTokenSelected;

  const LudoBoard({
    super.key,
    required this.gameData,
    required this.currentUserId,
    required this.onTokenSelected,
  });

  @override
  Widget build(BuildContext context) {
    final players = gameData['players'] as Map<dynamic, dynamic>;
    final playerIds = players.keys.cast<String>().toList();
    final currentPlayerIndex = gameData['currentPlayerIndex'] as int;
    final currentPlayerId = playerIds[currentPlayerIndex];
    final isMyTurn = currentPlayerId == currentUserId;
    final turnState = gameData['turnState'] as String;
    final diceResult = gameData['diceResult'] as int;

    final List<Widget> tokens = [];
    final double boardSize = MediaQuery.of(context).size.width;
    final double tokenSize = boardSize / 20;

    players.forEach((playerId, playerData) {
      final colorName = playerData['color'] as String;
      final color = _getColorForName(colorName);
      final playerTokens = playerData['tokens'] as List<dynamic>;

      for (int i = 0; i < playerTokens.length; i++) {
        final position = playerTokens[i] as int;
        final isSelectable = isMyTurn &&
            playerId == currentUserId &&
            turnState == 'moving' &&
            GameService().isValidMove(playerTokens, position, diceResult);

        final offset = GamePath.getOffsetForPosition(colorName, position, boardSize, i);
        tokens.add(
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500), // Animation duration
            curve: Curves.easeInOut, // Animation curve
            left: offset.dx,
            top: offset.dy,
            child: TokenWidget(
              color: color,
              size: tokenSize,
              isSelectable: isSelectable,
              onTap: isSelectable ? () => onTokenSelected(i) : null,
            ),
          ),
        );
      }
    });

    return AspectRatio(
      aspectRatio: 1.0,
      child: Stack(
        children: [
          CustomPaint(
            size: Size.infinite,
            painter: LudoBoardPainter(),
          ),
          ...tokens,
        ],
      ),
    );
  }

  Color _getColorForName(String colorName) {
    switch (colorName) {
      case 'red':
        return Colors.red.shade400;
      case 'green':
        return Colors.green.shade400;
      case 'yellow':
        return Colors.yellow.shade400;
      case 'blue':
        return Colors.blue.shade400;
      default:
        return Colors.grey;
    }
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:myapp/features/game/services/game_service.dart';
import 'package:myapp/features/game/services/sound_service.dart';
import 'package:myapp/features/game/widgets/dice_widget.dart';
import 'package:myapp/features/game/widgets/game_message_widget.dart';
import 'package:myapp/features/game/widgets/ludo_board.dart';

/// The main screen for the Ludo game.
///
/// This screen displays the game board, player information, and handles all
/// user interactions during gameplay. It uses a [StreamBuilder] to listen for
/// real-time updates from Firebase and rebuilds the UI accordingly.
class GameScreen extends StatefulWidget {
  final String roomId;
  const GameScreen({super.key, required this.roomId});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameService _gameService = GameService();
  final SoundService _soundService = SoundService();
  final String _userId = FirebaseAuth.instance.currentUser!.uid;

  /// Handles the selection of a token by the current player.
  ///
  /// This method calculates the new position of the selected token, moves it,
  /// and then advances the game to the next turn or resets the turn if a 6 was rolled.
  Future<void> _onTokenSelected(int tokenIndex, Map<dynamic, dynamic> gameData) async {
    final players = gameData['players'] as Map<dynamic, dynamic>;
    final playerIds = players.keys.cast<String>().toList();
    final currentPlayerIndex = gameData['currentPlayerIndex'] as int;
    final currentPlayerId = playerIds[currentPlayerIndex];
    final playerData = players[currentPlayerId];
    final playerColor = playerData['color'] as String;
    final playerTokens = playerData['tokens'] as List<dynamic>;
    final currentPosition = playerTokens[tokenIndex] as int;
    final diceResult = gameData['diceResult'] as int;

    // Calculate the new position and move the token.
    final newPosition = _gameService.getNewPosition(playerColor, currentPosition, diceResult);
    await _gameService.moveToken(widget.roomId, currentPlayerId, tokenIndex, newPosition);

    // Check for a win condition after the move.
    final updatedGameSnapshot = await _gameService.getGameStream(widget.roomId).first;
    final updatedGameData = updatedGameSnapshot.snapshot.value as Map<dynamic, dynamic>;
    final updatedPlayerTokens = updatedGameData['players'][currentPlayerId]['tokens'] as List<dynamic>;

    if (updatedPlayerTokens.every((pos) => pos >= 57)) {
      _showWinnerDialog(players[currentPlayerId]['name']);
    } else {
      // If a 6 was rolled, the player gets another turn.
      if (diceResult == 6) {
        _gameService.resetTurn(widget.roomId);
      } else {
        _gameService.nextTurn(widget.roomId, currentPlayerIndex, playerIds.length);
      }
    }
  }

  /// Displays a dialog to announce the winner of the game.
  void _showWinnerDialog(String winnerName) {
    _soundService.playWinSound();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Game Over'),
        content: Text('$winnerName has won the game!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Builds the informational message displayed to the players.
  ///
  /// This message provides context about the current state of the game,
  /// such as whose turn it is, the result of a dice roll, or if a player has won.
  String _buildGameMessage(Map<dynamic, dynamic> gameData, String currentUserId) {
    final players = gameData['players'] as Map<dynamic, dynamic>;
    final playerIds = players.keys.cast<String>().toList();
    final currentPlayerIndex = gameData['currentPlayerIndex'] as int;
    final currentPlayerId = playerIds[currentPlayerIndex];
    final currentPlayerName = players[currentPlayerId]?['name'] ?? 'Player';
    final turnState = gameData['turnState'] as String;
    final diceResult = gameData['diceResult'] as int;
    final isMyTurn = currentPlayerId == currentUserId;

    if (turnState == 'rolling') {
      if (isMyTurn) {
        return diceResult == 6 ? 'You rolled a 6! Roll again.' : 'Your turn to roll the dice!';
      } else {
        return "Waiting for $currentPlayerName to roll...";
      }
    }

    if (turnState == 'moving') {
      if (isMyTurn) {
        return 'You rolled a $diceResult. Choose a token to move.';
      } else {
        return '$currentPlayerName rolled a $diceResult.';
      }
    }

    return 'Welcome to Ludo!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ludo Game - Room: ${widget.roomId}'),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _gameService.getGameStream(widget.roomId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text('Game not found'));
          }

          final gameData = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          final players = gameData['players'] as Map<dynamic, dynamic>;
          final playerIds = players.keys.cast<String>().toList();
          final currentPlayerIndex = gameData['currentPlayerIndex'] as int;
          final currentPlayerId = playerIds[currentPlayerIndex];
          final isMyTurn = currentPlayerId == _userId;
          final turnState = gameData['turnState'] as String;
          final diceResult = gameData['diceResult'] as int;

          final gameMessage = _buildGameMessage(gameData, _userId);

          return Column(
            children: [
              // The main Ludo board widget.
              Expanded(
                child: LudoBoard(
                  gameData: gameData,
                  currentUserId: _userId,
                  onTokenSelected: (tokenIndex) => _onTokenSelected(tokenIndex, gameData),
                ),
              ),
              // The bottom panel with player info, dice, and roll button.
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text('Current Turn:', style: Theme.of(context).textTheme.titleMedium),
                        Text(players[currentPlayerId]?['name'] ?? 'Player', style: Theme.of(context).textTheme.titleLarge),
                      ],
                    ),
                    DiceWidget(result: diceResult),
                    // Show the roll button only when it's the player's turn to roll.
                    if (isMyTurn && turnState == 'rolling')
                      ElevatedButton(
                        onPressed: () => _gameService.rollDice(widget.roomId),
                        child: const Text('Roll Dice'),
                      ),
                    if (isMyTurn && turnState == 'moving')
                      const SizedBox(width: 80), // Placeholder for spacing
                  ],
                ),
              ),
              // The game message bar at the bottom.
              GameMessageWidget(message: gameMessage),
            ],
          );
        },
      ),
    );
  }
}

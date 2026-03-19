import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:myapp/features/game/services/sound_service.dart';

/// Manages the core game logic for the Ludo game.
///
/// This service interacts with Firebase Realtime Database to maintain game state
/// and handles all game-related actions, such as rolling the dice, moving tokens,
/// and determining win conditions.
class GameService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final SoundService _soundService = SoundService();

  // A list of board positions that are safe from captures.
  final List<int> _safeZones = [1, 9, 14, 22, 27, 35, 40, 48];

  // Defines the starting position and home entry point for each color.
  final Map<String, Map<String, int>> _playerPathData = {
    'red': {'start': 1, 'entry': 51},
    'green': {'start': 14, 'entry': 12},
    'yellow': {'start': 27, 'entry': 25},
    'blue': {'start': 40, 'entry': 38},
  };

  /// Initializes a new game with the given players.
  ///
  /// Sets up the initial game state in Firebase, including player data,
  /// token positions, and the starting turn.
  Future<void> initializeGame(String roomId, List<String> playerIds) async {
    final gameRef = _dbRef.child('games/$roomId');
    final colors = ['red', 'green', 'blue', 'yellow'];

    final Map<String, dynamic> initialGameState = {
      'players': {
        for (var i = 0; i < playerIds.length; i++)
          playerIds[i]: {
            'name': 'Player ${i + 1}',
            'tokens': [-1, -1, -1, -1], // -1 represents a token at base
            'color': colors[i]
          }
      },
      'currentPlayerIndex': 0,
      'diceResult': 0,
      'turnState': 'rolling', // Can be 'rolling' or 'moving'
    };

    await gameRef.set(initialGameState);
  }

  /// Rolls the dice for the current player.
  ///
  /// Generates a random dice result, checks for valid moves, and updates
  /// the game state accordingly. If no valid moves are available, the turn
  /// automatically passes to the next player (unless a 6 is rolled).
  Future<void> rollDice(String roomId) async {
    await _soundService.playDiceRollSound();
    final diceResult = Random().nextInt(6) + 1;
    final gameSnapshot = await _dbRef.child('games/$roomId').once(DatabaseEventType.value);
    final gameData = gameSnapshot.snapshot.value as Map<dynamic, dynamic>;
    final players = gameData['players'] as Map<dynamic, dynamic>;
    final playerIds = players.keys.cast<String>().toList();
    final currentPlayerIndex = gameData['currentPlayerIndex'] as int;
    final currentPlayerId = playerIds[currentPlayerIndex];
    final playerData = players[currentPlayerId];
    final playerTokens = playerData['tokens'] as List<dynamic>;
    final playerColor = playerData['color'] as String;

    // Check if the current player has any valid moves with the rolled dice.
    bool hasValidMove = false;
    for (final tokenPos in playerTokens) {
      if (isValidMove(playerColor, tokenPos as int, diceResult)) {
        hasValidMove = true;
        break;
      }
    }

    if (hasValidMove) {
      // If there's a valid move, update the state to 'moving'.
      await _dbRef.child('games/$roomId').update({
        'diceResult': diceResult,
        'turnState': 'moving',
      });
    } else {
      // If no valid moves, check if the player should get another turn (rolled a 6).
      if (diceResult == 6) {
        await resetTurn(roomId);
      } else {
        await nextTurn(roomId, currentPlayerIndex, playerIds.length);
      }
    }
  }

  /// Moves a player's token to a new position.
  ///
  /// Updates the token's position in Firebase. Also handles capturing opponent
  /// tokens if the new position is not a safe zone.
  Future<void> moveToken(String roomId, String playerId, int tokenIndex, int newPosition) async {
    await _soundService.playTokenMoveSound();
    final gameRef = _dbRef.child('games/$roomId');
    final gameSnapshot = await gameRef.once(DatabaseEventType.value);
    final gameData = gameSnapshot.snapshot.value as Map<dynamic, dynamic>;
    final players = gameData['players'] as Map<dynamic, dynamic>;

    Map<String, dynamic> updates = {};

    // Check for captures if the destination is not a safe zone.
    if (!_safeZones.contains(newPosition)) {
      bool captured = false;
      players.forEach((otherPlayerId, otherPlayerData) {
        if (otherPlayerId != playerId) {
          List<dynamic> otherTokens = otherPlayerData['tokens'];
          for (int i = 0; i < otherTokens.length; i++) {
            if (otherTokens[i] == newPosition) {
              // Send opponent's token back to base.
              updates['/players/$otherPlayerId/tokens/$i'] = -1;
              captured = true;
            }
          }
        }
      });
      if (captured) {
        await _soundService.playCaptureSound();
      }
    }

    updates['/players/$playerId/tokens/$tokenIndex'] = newPosition;

    await gameRef.update(updates);
  }

  /// Passes the turn to the next player.
  Future<void> nextTurn(String roomId, int currentPlayerIndex, int totalPlayers) async {
    final nextPlayerIndex = (currentPlayerIndex + 1) % totalPlayers;
    await _dbRef.child('games/$roomId').update({
      'currentPlayerIndex': nextPlayerIndex,
      'diceResult': 0,
      'turnState': 'rolling',
    });
  }

  /// Resets the turn for the current player (e.g., after rolling a 6).
  Future<void> resetTurn(String roomId) async {
    await _dbRef.child('games/$roomId').update({
      'diceResult': 0,
      'turnState': 'rolling',
    });
  }

  /// Checks if a move is valid based on the game rules.
  bool isValidMove(String playerColor, int currentPosition, int diceResult) {
    // A token can only leave the base if a 6 is rolled.
    if (currentPosition == -1 && diceResult != 6) {
      return false;
    }

    final newPosition = getNewPosition(playerColor, currentPosition, diceResult);

    // If the new position is the same as the old one, the move is invalid (e.g., blocked or overshot).
    if (newPosition == currentPosition) {
      return false;
    }

    return true;
  }

  /// Calculates the new position of a token after a dice roll.
  ///
  /// This method contains the core logic for token movement, including handling
  /// the circular board path and the final home run for each color.
  int getNewPosition(String playerColor, int currentPosition, int diceResult) {
    if (currentPosition == -1) {
      return diceResult == 6 ? _playerPathData[playerColor]!['start']! : currentPosition;
    }

    if (currentPosition >= 52) {
      // Token is already in the home run.
      int newHomePos = currentPosition + diceResult;
      return newHomePos > 57 ? currentPosition : newHomePos;
    }

    int playerStart = _playerPathData[playerColor]!['start']!;
    int homeEntry = _playerPathData[playerColor]!['entry']!;

    int tempPos = currentPosition;
    for (int i = 0; i < diceResult; i++) {
      if (tempPos == homeEntry) {
        // Enters the home path.
        int homeRunSteps = diceResult - i;
        if (homeRunSteps > 6) return currentPosition; // Overshot.
        return 51 + homeRunSteps;
      }
      tempPos++;
      if (tempPos > 52) {
        tempPos = 1;
      }
    }
    return tempPos;
  }

  /// Returns a stream of game state updates from Firebase.
  Stream<DatabaseEvent> getGameStream(String roomId) {
    return _dbRef.child('games/$roomId').onValue;
  }
}

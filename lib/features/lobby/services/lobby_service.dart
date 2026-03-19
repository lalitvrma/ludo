import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class LobbyService {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Generates a random 6-digit room code.
  String _generateRoomId() {
    return (100000 + Random().nextInt(900000)).toString();
  }

  /// Creates a new game room in the Realtime Database.
  /// Returns the unique room ID.
  Future<String> createRoom() async {
    final roomId = _generateRoomId();
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('User not logged in');
    }

    final roomRef = _dbRef.child('rooms/$roomId');

    await roomRef.set({
      'host': user.uid,
      'players': {user.uid: {'name': user.displayName ?? 'Guest', 'isReady': false}},
      'createdAt': ServerValue.timestamp,
      'status': 'waiting', // waiting, in_game, finished
    });

    return roomId;
  }

  /// Allows a user to join an existing game room.
  Future<void> joinRoom(String roomId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    final roomRef = _dbRef.child('rooms/$roomId');
    final snapshot = await roomRef.get();

    if (!snapshot.exists) {
      throw Exception('Room not found');
    }

    // You might want to add more checks here, e.g., if the room is full.

    await roomRef.child('players/${user.uid}').set({
      'name': user.displayName ?? 'Guest',
      'isReady': false,
    });
  }

  /// Returns a stream of the game room data for real-time updates.
  Stream<DatabaseEvent> getRoomStream(String roomId) {
    return _dbRef.child('rooms/$roomId').onValue;
  }

  /// Toggles the ready status of a player in a room.
  Future<void> togglePlayerReady(String roomId) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User not logged in');
    }

    final playerRef = _dbRef.child('rooms/$roomId/players/${user.uid}/isReady');
    final snapshot = await playerRef.get();
    
    if(snapshot.exists){
       await playerRef.set(!((snapshot.value) as bool));
    }
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/features/game/services/game_service.dart';
import 'package:myapp/features/lobby/services/lobby_service.dart';

class WaitingRoomScreen extends StatefulWidget {
  final String roomId;
  const WaitingRoomScreen({super.key, required this.roomId});

  @override
  State<WaitingRoomScreen> createState() => _WaitingRoomScreenState();
}

class _WaitingRoomScreenState extends State<WaitingRoomScreen> {
  final LobbyService _lobbyService = LobbyService();
  final GameService _gameService = GameService();
  final String _userId = FirebaseAuth.instance.currentUser!.uid;

  void _toggleReady() {
    _lobbyService.togglePlayerReady(widget.roomId);
  }

  void _startGame(List<String> playerIds) {
    _gameService.initializeGame(widget.roomId, playerIds);
    context.go('/game/${widget.roomId}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Room: ${widget.roomId}'),
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: _lobbyService.getRoomStream(widget.roomId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text('Room not found'));
          }

          final roomData = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
          final players = roomData['players'] as Map<dynamic, dynamic>;
          final playerIds = players.keys.cast<String>().toList();
          final isHost = roomData['host'] == _userId;
          final allPlayersReady = players.values.every((player) => player['isReady'] == true);

          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: players.length,
                  itemBuilder: (context, index) {
                    final player = players.values.elementAt(index);
                    return ListTile(
                      title: Text(player['name'] ?? 'Guest'),
                      trailing: Text(player['isReady'] ? 'Ready' : 'Not Ready'),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: _toggleReady,
                      child: const Text('Toggle Ready'),
                    ),
                    if (isHost)
                      ElevatedButton(
                        onPressed: allPlayersReady ? () => _startGame(playerIds) : null,
                        child: const Text('Start Game'),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

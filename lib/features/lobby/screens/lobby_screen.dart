import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:myapp/features/lobby/services/lobby_service.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({super.key});

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  final LobbyService _lobbyService = LobbyService();
  final TextEditingController _roomCodeController = TextEditingController();
  bool _isLoading = false;

  void _createRoom() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final roomId = await _lobbyService.createRoom();
      context.go('/lobby/waiting/$roomId');
    } catch (e) {
      // Handle error
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _joinRoom() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _lobbyService.joinRoom(_roomCodeController.text);
      context.go('/lobby/waiting/${_roomCodeController.text}');
    } catch (e) {
      // Handle error
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lobby'),
      ),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _createRoom,
                    child: const Text('Create Room'),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _roomCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Enter Room Code',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: _joinRoom,
                    child: const Text('Join Room'),
                  ),
                ],
              ),
      ),
    );
  }
}

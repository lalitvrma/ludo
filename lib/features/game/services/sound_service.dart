import 'package:audioplayers/audioplayers.dart';

class SoundService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playDiceRollSound() async {
    await _audioPlayer.play(AssetSource('sounds/roll.mp3'));
  }

  Future<void> playTokenMoveSound() async {
    await _audioPlayer.play(AssetSource('sounds/move.mp3'));
  }

  Future<void> playCaptureSound() async {
    await _audioPlayer.play(AssetSource('sounds/capture.mp3'));
  }

  Future<void> playWinSound() async {
    await _audioPlayer.play(AssetSource('sounds/win.mp3'));
  }
}

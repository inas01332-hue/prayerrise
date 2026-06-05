import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';

class AdhanPlayer {
  // Singleton instance
  static final AdhanPlayer instance = AdhanPlayer._internal();

  late final AudioPlayer _player;
  String statusMessage = "🔊 Adhan Ready";
  void Function(String)? onStatusChanged;

  AdhanPlayer._internal() {
    _player = AudioPlayer();
    _initialize();
  }

  void _updateStatus(String message) {
    statusMessage = message;
    if (onStatusChanged != null) {
      onStatusChanged!(message);
    }
  }

  Future<void> _initialize() async {
    _updateStatus("Initializing...");
    // Configure the audio session for playback.
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.speech());
      _updateStatus("Loading...");
      await _player.setAsset('assets/audio/adhan.mp3');
      _updateStatus("🔊 Adhan Ready");
    } catch (e) {
      _updateStatus("Error: $e");
      print('AdhanPlayer: Failed to load asset: $e');
    }
  }

  /// Plays the adhan. Optionally set a playback [speed] (default 1.0).
  Future<void> play({double speed = 1.0}) async {
    try {
      _updateStatus("Playing...");
      if (_player.playerState.processingState == ProcessingState.idle) {
        await _player.setAsset('assets/audio/adhan.mp3');
      }
      await _player.setSpeed(speed);
      await _player.play();
      _updateStatus("🔊 Playing");
    } catch (e) {
      _updateStatus("Playback error: $e");
      print('AdhanPlayer: Playback error: $e');
    }
  }

  /// Stops playback if needed.
  Future<void> stop() async {
    try {
      await _player.stop();
      _updateStatus("🔊 Adhan Ready");
    } catch (e) {
      _updateStatus("Stop error: $e");
    }
  }
}

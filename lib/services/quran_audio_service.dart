import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class QuranAudioService extends ChangeNotifier {
  static final QuranAudioService _instance =
      QuranAudioService._internal();

  factory QuranAudioService() => _instance;

  QuranAudioService._internal() {
    init();
  }

  final AudioPlayer _player = AudioPlayer();

  PlayerState _playerState = PlayerState.stopped;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  String? _currentUrl;
  bool _isLooping = false;
  double _playbackSpeed = 1.0;

  StreamSubscription<PlayerState>? _stateSub;
  StreamSubscription<Duration>? _positionSub;
  StreamSubscription<Duration>? _durationSub;

  PlayerState get playerState => _playerState;
  bool get isPlaying => _playerState == PlayerState.playing;
  Duration get position => _position;
  Duration get duration => _duration;
  String? get currentUrl => _currentUrl;

  bool get isLooping => _isLooping;
  double get playbackSpeed => _playbackSpeed;

  Stream<void> get onComplete => _player.onPlayerComplete;

  Future<void> init() async {
    _stateSub ??=
        _player.onPlayerStateChanged.listen((state) {
      _playerState = state;
      notifyListeners();
    });

    _positionSub ??=
        _player.onPositionChanged.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    _durationSub ??=
        _player.onDurationChanged.listen((dur) {
      _duration = dur;
      notifyListeners();
    });
  }

  Future<void> play(String url) async {
    try {
      _currentUrl = url;
      await _player.play(UrlSource(url));
    } catch (e) {
      debugPrint("Audio error: $e");
    }
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> resume() async {
    await _player.resume();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> setLoop(bool loop) async {
    _isLooping = loop;

    await _player.setReleaseMode(
      loop ? ReleaseMode.loop : ReleaseMode.release,
    );

    notifyListeners();
  }

  Future<void> setSpeed(double speed) async {
    _playbackSpeed = speed;
    await _player.setPlaybackRate(speed);
    notifyListeners();
  }

  @override
  void dispose() {
    _stateSub?.cancel();
    _positionSub?.cancel();
    _durationSub?.cancel();
    _player.dispose();
    super.dispose();
  }
}
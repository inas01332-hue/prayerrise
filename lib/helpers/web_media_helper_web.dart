// Real web implementation using dart:js_interop and web package APIs.
// Provides live camera viewfinder and real-time microphone frequency analysis.

import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:web/web.dart' as web;
import 'dart:ui_web' as ui_web;

// ──────────────────────── Internal State ────────────────────────
web.MediaStream? _cameraStream;
web.HTMLVideoElement? _videoElement;

web.MediaStream? _micStream;
JSObject? _audioContext;    // AudioContext
JSObject? _analyserNode;    // AnalyserNode
JSObject? _micSourceNode;   // MediaStreamAudioSourceNode

// ──────────────────────── JS Interop Helpers ────────────────────
// We use callMethod via dart:js_interop_unsafe for Web Audio API
// since it's not fully covered by package:web yet.

// ──────────────────────── Camera ────────────────────────────────

/// Register a platform view with a live <video> element showing the webcam feed.
Future<void> initCameraView(String viewId) async {
  try {
    final constraints = {
      'video': {
        'facingMode': 'user',
        'width': {'ideal': 320},
        'height': {'ideal': 320},
      }.jsify(),
      'audio': false.toJS,
    }.jsify() as web.MediaStreamConstraints;

    final stream = await web.window.navigator.mediaDevices
        .getUserMedia(constraints)
        .toDart;

    _cameraStream = stream;

    final video = web.document.createElement('video') as web.HTMLVideoElement;
    video.srcObject = stream;
    video.autoplay = true;
    video.setAttribute('playsinline', 'true');
    video.muted = true;
    video.style
      ..width = '100%'
      ..height = '100%'
      ..objectFit = 'cover'
      ..borderRadius = '50%'
      ..transform = 'scaleX(-1)'; // Mirror for selfie view

    _videoElement = video;

    // ignore: undefined_prefixed_name
    ui_web.platformViewRegistry.registerViewFactory(
      viewId,
      (int viewId) => video,
    );

    // Wait for the video to start playing
    await video.play().toDart;
  } catch (e) {
    // Camera permission denied or not available — silently degrade
    // The UI will show a fallback icon.
  }
}

// ──────────────────────── Microphone ────────────────────────────

/// Initialize real-time microphone analyser using Web Audio API.
Future<void> initMicrophoneAnalyser() async {
  try {
    final constraints = {
      'audio': true.toJS,
      'video': false.toJS,
    }.jsify() as web.MediaStreamConstraints;

    final stream = await web.window.navigator.mediaDevices
        .getUserMedia(constraints)
        .toDart;
    _micStream = stream;

    // Create AudioContext
    final ctx = web.AudioContext();
    _audioContext = ctx as JSObject;

    // Create AnalyserNode
    final analyser = ctx.createAnalyser();
    (analyser as JSObject).setProperty('fftSize'.toJS, 2048.toJS);
    (analyser as JSObject).setProperty('smoothingTimeConstant'.toJS, 0.8.toJS);
    _analyserNode = analyser as JSObject;

    // Connect microphone stream -> analyser
    final source = ctx.createMediaStreamSource(stream);
    source.connect(analyser);
    _micSourceNode = source as JSObject;
  } catch (e) {
    // Mic permission denied — silently degrade
  }
}

/// Get the current waveform bar heights from real mic data.
/// Returns a list of [binCount] values in the range [4.0 .. 36.0].
List<double> getMicrophoneWaveform(int binCount) {
  if (_analyserNode == null) {
    return List.filled(binCount, 4.0);
  }

  try {
    final analyser = _analyserNode!;
    final bufferLength = (analyser.getProperty('frequencyBinCount'.toJS) as JSNumber).toDartInt;

    // Create a Uint8Array via JS constructor (needs int arg, not JSArrayBuffer)
    final uint8Constructor = globalContext.getProperty('Uint8Array'.toJS) as JSFunction;
    final dataArray = uint8Constructor.callAsConstructor<JSUint8Array>(bufferLength.toJS);

    // getByteFrequencyData fills the array with 0-255 frequency magnitudes
    analyser.callMethod('getByteFrequencyData'.toJS, dataArray);

    // Convert to Dart for easy indexing
    final Uint8List dartData = dataArray.toDart;

    final List<double> waveform = [];
    // Sample evenly across the frequency range
    final step = bufferLength ~/ binCount;
    for (int i = 0; i < binCount; i++) {
      final idx = math.min(i * step, bufferLength - 1);
      final raw = dartData[idx].toDouble();
      // Normalize 0-255 → 4.0-36.0
      waveform.add(4.0 + (raw / 255.0) * 32.0);
    }
    return waveform;
  } catch (e) {
    return List.filled(binCount, 4.0);
  }
}

/// Get the dominant frequency from the mic analyser.
/// Returns Hz value (e.g. ~200-300 Hz for female voice).
double getDominantFrequency() {
  if (_analyserNode == null || _audioContext == null) {
    return 0.0;
  }

  try {
    final analyser = _analyserNode!;
    final ctx = _audioContext!;
    final bufferLength = (analyser.getProperty('frequencyBinCount'.toJS) as JSNumber).toDartInt;

    // Create a Uint8Array via JS constructor
    final uint8Constructor = globalContext.getProperty('Uint8Array'.toJS) as JSFunction;
    final dataArray = uint8Constructor.callAsConstructor<JSUint8Array>(bufferLength.toJS);

    analyser.callMethod('getByteFrequencyData'.toJS, dataArray);

    // Convert to Dart for easy indexing
    final Uint8List dartData = dataArray.toDart;

    final sampleRate = (ctx.getProperty('sampleRate'.toJS) as JSNumber).toDartDouble;

    // Find the bin with the highest magnitude
    int maxIndex = 0;
    double maxValue = 0.0;
    // Only scan voice-relevant range (~80 Hz to 400 Hz)
    final minBin = (80.0 * bufferLength * 2 / sampleRate).round();
    final maxBin = math.min((400.0 * bufferLength * 2 / sampleRate).round(), bufferLength - 1);

    for (int i = minBin; i <= maxBin; i++) {
      final val = dartData[i].toDouble();
      if (val > maxValue) {
        maxValue = val;
        maxIndex = i;
      }
    }

    // Convert bin index to frequency
    if (maxValue < 20) return 0.0; // Below noise floor
    return maxIndex * sampleRate / (bufferLength * 2);
  } catch (e) {
    return 0.0;
  }
}

// ──────────────────────── Cleanup ───────────────────────────────

void disposeCamera() {
  try {
    if (_cameraStream != null) {
      final tracks = _cameraStream!.getTracks().toDart;
      for (final track in tracks) {
        track.stop();
      }
    }
    _cameraStream = null;
    _videoElement = null;
  } catch (_) {}
}

void disposeMicrophone() {
  try {
    if (_micStream != null) {
      final tracks = _micStream!.getTracks().toDart;
      for (final track in tracks) {
        track.stop();
      }
    }
    if (_audioContext != null) {
      _audioContext!.callMethod('close'.toJS);
    }
    _micStream = null;
    _audioContext = null;
    _analyserNode = null;
    _micSourceNode = null;
  } catch (_) {}
}

/// Whether the platform supports live media.
bool isWebPlatform() => true;

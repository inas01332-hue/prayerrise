// Stub implementation for non-web platforms.
// All methods are no-ops so the app compiles on Android/iOS/desktop.

import 'dart:async';

/// Initialize the camera platform view (no-op on non-web).
Future<void> initCameraView(String viewId) async {}

/// Initialize the microphone analyser (no-op on non-web).
Future<void> initMicrophoneAnalyser() async {}

/// Get the current waveform frequency bins from the mic (returns flat line on non-web).
List<double> getMicrophoneWaveform(int binCount) {
  return List.filled(binCount, 4.0);
}

/// Get the dominant frequency detected by the mic analyser (returns 0 on non-web).
double getDominantFrequency() {
  return 0.0;
}

/// Stop and dispose the camera stream (no-op on non-web).
void disposeCamera() {}

/// Stop and dispose the microphone analyser (no-op on non-web).
void disposeMicrophone() {}

/// Whether the platform supports live media (always false on non-web).
bool isWebPlatform() => false;

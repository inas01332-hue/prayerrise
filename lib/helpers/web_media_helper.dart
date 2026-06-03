// Conditional import barrel for web camera/microphone helpers.
// On web: uses dart:html and dart:js_interop via web_media_helper_web.dart
// On other platforms: uses stub with no-op implementations.

export 'web_media_helper_stub.dart'
    if (dart.library.js_interop) 'web_media_helper_web.dart';

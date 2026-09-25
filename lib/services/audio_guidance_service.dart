import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Narração em áudio (pt-BR) das instruções de navegação.
///
/// Complementa a sinalização em Libras do avatar 3D. O [NavigationScreen]
/// consulta [enabled] antes de chamar [speak]; a classe permanece mockável
/// em testes por ter métodos virtuais.
class AudioGuidanceService extends ChangeNotifier {
  final FlutterTts _tts;
  bool _enabled;
  bool _initialized = false;

  AudioGuidanceService({FlutterTts? tts, bool enabled = true})
      : _tts = tts ?? FlutterTts(),
        _enabled = enabled;

  bool get enabled => _enabled;

  set enabled(bool value) {
    if (_enabled == value) return;
    _enabled = value;
    if (!value) {
      stop();
    }
    notifyListeners();
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    try {
      await _tts.setLanguage('pt-BR');
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
    } catch (e) {
      debugPrint('AudioGuidanceService: falha ao configurar TTS: $e');
    }
    _initialized = true;
  }

  /// Fala [text] em voz alta quando [enabled] estiver ativo.
  Future<void> speak(String text) async {
    if (!_enabled || text.trim().isEmpty) return;
    try {
      await _ensureInitialized();
      await _tts.stop();
      await _tts.speak(text);
    } catch (e) {
      debugPrint('AudioGuidanceService.speak: $e');
    }
  }

  Future<void> stop() async {
    try {
      await _tts.stop();
    } catch (e) {
      debugPrint('AudioGuidanceService.stop: $e');
    }
  }

  @override
  void dispose() {
    stop();
    super.dispose();
  }
}

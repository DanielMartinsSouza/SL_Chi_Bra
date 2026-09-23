import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VLibrasPlayerController extends ChangeNotifier {
  WebViewController? webViewController;
  bool _isReady = false;
  double _loadProgress = 0.0;
  String _currentGlossProgress = '';

  bool get isReady => _isReady;
  double get loadProgress => _loadProgress;
  String get currentGlossProgress => _currentGlossProgress;

  void initialize({
    required Function(String event, dynamic data) onEvent,
    required Function(String error) onError,
  }) {
    try {
      webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0xFF121212))
        ..addJavaScriptChannel(
          'FlutterBridge',
          onMessageReceived: (JavaScriptMessage message) {
            try {
              final parsed = jsonDecode(message.message);
              final event = parsed['event'] as String;
              final data = parsed['data'];

              if (event == 'onReady') {
                _isReady = true;
                notifyListeners();
              } else if (event == 'onProgress') {
                if (data is num) {
                  _loadProgress = data.toDouble();
                  notifyListeners();
                }
              } else if (event == 'onGlossProgress') {
                if (data is List && data.length >= 2) {
                  _currentGlossProgress = '${data[0]}/${data[1]}';
                  notifyListeners();
                }
              }

              onEvent(event, data);
            } catch (e) {
              onError('Erro no processamento da mensagem do player: $e');
            }
          },
        )
        ..loadFlutterAsset('assets/vlibras_player.html');
    } on AssertionError catch (_) {
      debugPrint(
          'WebView não disponível nesta plataforma; o player será ignorado.');
      _isReady = false;
    }
  }

  Future<void> playGloss(String gloss) async {
    if (!_isReady || webViewController == null) {
      return;
    }

    final jsonGloss = jsonEncode(gloss);
    await webViewController!.runJavaScript('window.playGloss($jsonGloss);');
  }

  Future<void> stop() async {
    if (!_isReady || webViewController == null) {
      return;
    }

    await webViewController!.runJavaScript('window.stopSignaling();');
  }
}

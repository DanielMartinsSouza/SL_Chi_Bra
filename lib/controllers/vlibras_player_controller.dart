import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VLibrasPlayerController extends ChangeNotifier {
  late final WebViewController webViewController;
  bool _isReady = false;
  double _loadProgress = 0.0;
  String _currentGlossProgress = '';
  final Completer<void> _ready = Completer<void>();
  String? _loadError;

  bool get isReady => _isReady;
  double get loadProgress => _loadProgress;
  String get currentGlossProgress => _currentGlossProgress;

  void initialize({
    required Function(String event, dynamic data) onEvent,
    required Function(String error) onError,
  }) {
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
              if (!_ready.isCompleted) _ready.complete();
              notifyListeners();
            } else if (event == 'onError' && !_ready.isCompleted) {
              _loadError = data.toString();
              _ready.complete();
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
  }

  Future<void> playGloss(String gloss) async {
    await _ready.future.timeout(
      const Duration(seconds: 45),
      onTimeout: () =>
          throw TimeoutException('O avatar do VLibras não carregou.'),
    );
    if (_loadError != null) throw Exception(_loadError);
    final jsonGloss = jsonEncode(gloss);
    await webViewController.runJavaScript('window.playGloss($jsonGloss);');
  }

  Future<void> stop() async {
    await webViewController.runJavaScript('window.stopSignaling();');
  }
}

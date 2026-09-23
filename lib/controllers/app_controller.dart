import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import '../models/app_state.dart';
import '../services/permission_service.dart';
import '../services/speech_service.dart';
import '../services/vlibras_translation_service.dart';
import 'vlibras_player_controller.dart';

class AppController extends ChangeNotifier {
  final SpeechService _speechService;
  final VLibrasTranslationService _translationService;
  final PermissionService _permissionService;
  final VLibrasPlayerController playerController;

  final TextEditingController textEditingController = TextEditingController();

  AppState _state = AppState.idle;
  String _glossText = '';
  String _errorMessage = '';

  AppState get state => _state;
  String get glossText => _glossText;
  String get errorMessage => _errorMessage;

  AppController({
    SpeechService? speechService,
    VLibrasTranslationService? translationService,
    PermissionService? permissionService,
    VLibrasPlayerController? playerController,
  })  : _speechService = speechService ?? SpeechService(),
        _translationService = translationService ?? VLibrasTranslationService(),
        _permissionService = permissionService ?? PermissionService(),
        playerController = playerController ?? VLibrasPlayerController() {
    _initPlayer();
  }

  void _initPlayer() {
    playerController.initialize(
      onEvent: (event, data) {
        if (event == 'onReady') {
          if (_state == AppState.loadingPlayer || _state == AppState.idle) {
            _setState(AppState.idle);
          }
        } else if (event == 'onPlaying') {
          _setState(AppState.playing);
        } else if (event == 'onStopped') {
          _setState(AppState.stopped);
        } else if (event == 'onError') {
          _setError(data.toString());
        }
      },
      onError: (err) => _setError(err),
    );
  }

  void _setState(AppState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String errorMsg) {
    _errorMessage = errorMsg;
    _state = AppState.error;
    notifyListeners();
  }

  Future<void> handleMicButtonPress() async {
    if (_state == AppState.listening) {
      await stopListening();
      return;
    }

    _setState(AppState.requestingPermission);
    final granted = await _permissionService.requestMicrophonePermission();

    if (!granted) {
      _setError('Permissão de microfone não concedida.');
      return;
    }

    bool initialized = await _speechService.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (_state == AppState.listening) {
            _setState(AppState.readyToTranslate);
          }
        }
      },
      onError: (SpeechRecognitionError error) {
        _setError('Erro de voz: ${error.errorMsg}');
      },
    );

    if (!initialized) {
      _setError('Reconhecimento de voz indisponível neste dispositivo.');
      return;
    }

    _setState(AppState.listening);
    await _speechService.startListening(
      localeId: 'pt_BR',
      onResult: (text, isFinal) {
        textEditingController.text = text;
        if (isFinal) {
          _setState(AppState.readyToTranslate);
        }
        notifyListeners();
      },
    );
  }

  Future<void> stopListening() async {
    await _speechService.stopListening();
    _setState(AppState.readyToTranslate);
  }

  Future<void> translateAndPlay() async {
    final text = textEditingController.text.trim();
    if (text.isEmpty) {
      _setError('Digite ou fale um texto em português para traduzir.');
      return;
    }

    _setState(AppState.translating);
    _errorMessage = '';

    try {
      final gloss = await _translationService.translateToGloss(text);
      _glossText = gloss;
      notifyListeners();

      if (!playerController.isReady) {
        _setState(AppState.loadingPlayer);
      }

      await playerController.playGloss(gloss);
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> stopPlayer() async {
    await playerController.stop();
    _setState(AppState.stopped);
  }

  void clearText() {
    textEditingController.clear();
    _glossText = '';
    _setState(AppState.idle);
  }
}

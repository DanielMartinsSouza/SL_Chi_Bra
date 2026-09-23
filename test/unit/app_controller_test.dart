import 'package:china_brasil_sl/controllers/app_controller.dart';
import 'package:china_brasil_sl/controllers/vlibras_player_controller.dart';
import 'package:china_brasil_sl/services/permission_service.dart';
import 'package:china_brasil_sl/services/speech_service.dart';
import 'package:china_brasil_sl/services/vlibras_translation_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:speech_to_text/speech_recognition_error.dart';

class FakePermissionService extends PermissionService {
  @override
  Future<bool> requestMicrophonePermission() async => true;
}

class FakeSpeechService extends SpeechService {
  Function(String text, bool isFinal)? _onResult;

  @override
  Future<bool> initialize({
    required Function(String status) onStatus,
    required Function(SpeechRecognitionError error) onError,
  }) async {
    return true;
  }

  @override
  Future<void> startListening({
    required Function(String text, bool isFinal) onResult,
    required String localeId,
  }) async {
    _onResult = onResult;
  }

  @override
  Future<void> stopListening() async {}

  Future<void> emitResult(String text, bool isFinal) async {
    await _onResult?.call(text, isFinal);
  }
}

class FakeTranslationService extends VLibrasTranslationService {
  @override
  Future<String> translateToGloss(String text) async => 'glosa:$text';
}

class FakePlayerController extends VLibrasPlayerController {
  String? lastGloss;

  @override
  bool get isReady => true;

  @override
  void initialize({
    required Function(String event, dynamic data) onEvent,
    required Function(String error) onError,
  }) {}

  @override
  Future<void> playGloss(String gloss) async {
    lastGloss = gloss;
  }

  @override
  Future<void> stop() async {}
}

void main() {
  test(
      'Ao receber resultado final da fala, o texto é preenchido e a tradução é disparada',
      () async {
    final speechService = FakeSpeechService();
    final translationService = FakeTranslationService();
    final playerController = FakePlayerController();

    final controller = AppController(
      speechService: speechService,
      translationService: translationService,
      permissionService: FakePermissionService(),
      playerController: playerController,
    );

    await controller.handleMicButtonPress();
    await speechService.emitResult('bom dia', true);

    expect(controller.textEditingController.text, 'bom dia');
    expect(playerController.lastGloss, 'glosa:bom dia');
    expect(controller.glossText, 'glosa:bom dia');
  });
}

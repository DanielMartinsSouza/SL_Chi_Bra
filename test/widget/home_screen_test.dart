import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';
import 'package:china_brasil_sl/controllers/app_controller.dart';
import 'package:china_brasil_sl/models/app_state.dart';
import 'package:china_brasil_sl/presentation/screens/home_screen.dart';
import 'package:china_brasil_sl/services/vlibras_translation_service.dart';

class TestWebViewPlatform extends WebViewPlatform {
  late TestWebViewController controller;

  @override
  PlatformWebViewController createPlatformWebViewController(
      PlatformWebViewControllerCreationParams params) {
    return controller = TestWebViewController(params);
  }

  @override
  PlatformWebViewWidget createPlatformWebViewWidget(
          PlatformWebViewWidgetCreationParams params) =>
      TestWebViewWidget(params);
}

class TestWebViewController extends PlatformWebViewController {
  TestWebViewController(super.params) : super.implementation();

  void Function(JavaScriptMessage)? onMessage;
  final scripts = <String>[];

  @override
  Future<void> setJavaScriptMode(JavaScriptMode mode) async {}
  @override
  Future<void> setBackgroundColor(Color color) async {}
  @override
  Future<void> addJavaScriptChannel(JavaScriptChannelParams params) async {
    onMessage = params.onMessageReceived;
  }

  @override
  Future<void> loadFlutterAsset(String key) async {}
  @override
  Future<void> runJavaScript(String javaScript) async {
    scripts.add(javaScript);
    if (javaScript.contains('playGloss')) {
      onMessage!(JavaScriptMessage(
          message: jsonEncode({'event': 'onPlaying', 'data': 'GLOSA'})));
    }
  }

  void ready() => onMessage!(JavaScriptMessage(
      message: jsonEncode({'event': 'onReady', 'data': 'ready'})));
}

class TestWebViewWidget extends PlatformWebViewWidget {
  TestWebViewWidget(super.params) : super.implementation();

  @override
  Widget build(BuildContext context) => const ColoredBox(color: Colors.black);
}

void main() {
  testWidgets('Aguarda o avatar e informa erro se ele não carregar', (tester) async {
    WebViewPlatform.instance = TestWebViewPlatform();
    final controller = AppController(
      translationService: VLibrasTranslationService(
        httpClient: MockClient((request) async => http.Response('GLOSA', 200)),
      ),
    );
    final request = controller.translateTextAndPlay('Siga em frente');
    await tester.pump();
    expect(controller.state, AppState.loadingPlayer);
    await tester.pump(const Duration(seconds: 46));
    await request;
    expect(controller.state, AppState.error);
    expect(controller.errorMessage, contains('não carregou'));
    controller.dispose();
  });

  testWidgets('Mapa e avatar aparecem juntos e Próximo envia outra glosa',
      (tester) async {
    final platform = TestWebViewPlatform();
    WebViewPlatform.instance = platform;
    final client = MockClient((request) async => http.Response('GLOSA', 200));
    await tester.pumpWidget(MaterialApp(
      home: HomeScreen(
        createController: () => AppController(
          translationService: VLibrasTranslationService(httpClient: client),
        ),
      ),
    ));
    await tester.pump();

    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.byType(WebViewWidget), findsOneWidget);
    expect(find.text('Siga em frente'), findsOneWidget);
    expect(platform.controller.scripts, isEmpty); // Still awaiting Unity.

    platform.controller.ready();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
    expect(platform.controller.scripts, contains('window.playGloss("GLOSA");'));

    await tester.tap(find.text('Próximo'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
    expect(find.text('Vire para a direita'), findsOneWidget);
    expect(
        platform.controller.scripts
            .where((s) => s.contains('playGloss'))
            .length,
        2);

    await tester.tap(find.text('Tradutor'));
    await tester.pump();
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byType(WebViewWidget), findsOneWidget);
  });
}

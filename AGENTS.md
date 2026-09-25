# AGENTS.md — china_brasil_sl

Flutter app: pt-BR voice/text → Libras gloss via VLibras API → 3D avatar in WebView (Unity WebGL).

## Commands

- `flutter pub get` — install deps
- `flutter analyze` — lint (uses `package:flutter_lints`; `android/ ios/ web/ windows/ macos/ linux/ build/` excluded in `analysis_options.yaml`)
- `flutter test` — all tests; `flutter test test/unit/vlibras_translation_service_test.dart` or `test/widget/home_screen_test.dart` for a single file
- `flutter test <path> --plain-name "<test name>"` — single test
- `flutter run -d emulator-5554` — Android emulator demo; map tiles/VLibras/optional OSRM need internet. Only the separate speech translator needs a mic.
- Android SDK note: `compileSdk = 37` (`android/app/build.gradle.kts:9`), but Google now ships the platform as `platforms;android-37.0` (dir `android-37.0`), which AGP does not resolve as `android-37`. If the build fails with `Failed to find target with hash string 'android-37'`, symlink it: `ln -s android-37.0 android-37` in `$ANDROID_SDK_ROOT/platforms`, and ensure `build-tools;37.0.0` is installed via `sdkmanager`.

## Architecture

- Entry: `lib/main.dart` (`VLibrasApp` → `HomeScreen` hub). No routing, no DI framework.
- State: `lib/controllers/app_controller.dart` (`ChangeNotifier`, `AppState` in `lib/models/app_state.dart`) handles translation/player. `TranslatorScreen`/`NavigationScreen` accept `createController` for tests; `test/widget/home_screen_test.dart` fakes the WebView platform and uses an HTTP `MockClient`.
- Screens: `lib/presentation/screens/home_screen.dart` (hub com 2 cards) → `translator_screen.dart` (voz/texto livre) e `navigation_screen.dart` (mapa + avatar 3D + áudio via `AudioGuidanceService`/`flutter_tts` pt-BR).
- Navigation: `NavigationController` loads provider-independent `NavigationRoute`/`NavigationStep`. The fake route is default; cloud-download action swaps to OSRM for the same fixed Brasília endpoints. `lib/presentation/widgets/route_map.dart` uses `flutter_map` and public OSM tiles for this prototype; keep visible attribution and use a suitable hosted tile service for production. No GPS or location permission.
- Layers: `presentation/screens|widgets/` → `controllers/` → `services/` (`speech_service.dart`, `vlibras_translation_service.dart`, `permission_service.dart`) + `models/`.
- Player: `controllers/vlibras_player_controller.dart` wraps `WebViewController`, loads `assets/vlibras_player.html` (declared under `flutter.assets` in `pubspec.yaml`). Bridge: `FlutterBridge` JS channel (events `onReady onPlaying onStopped onError onProgress onGlossProgress`) + `window.playGloss(gloss)` / `window.stopSignaling()`.
- HTML (`assets/vlibras_player.html`) embeds Unity iframe `https://vlibras.gov.br/app/unity/index.html?v=7.12.2` with dict base `https://dicionario2.vlibras.gov.br/2018.3.1/WEBGL/` and avatar `icaro`. Do not change these URLs without verifying against vlibras.gov.br.

## Conventions / gotchas

- Translation API: `POST https://traducao2.vlibras.gov.br/translate` with body `{"text": ...}`, spoofed headers (`Origin: https://vlibras.gov.br`, `Referer`, mobile `User-Agent`), 12s timeout (`lib/services/vlibras_translation_service.dart:7-8`). Parser accepts JSON `{"traducao": ...}` or raw text; empty body → `FormatException`. Unit tests mock via `http/testing.dart` `MockClient` — follow that pattern, never hit the real API in tests.
- Navigation instruction wording is centralized in `lib/models/navigation_route.dart`; live VLibras returns HTTP 500 for `Vire à direita`, but `Vire para a direita` returned `VIRAR PARA DIREITA` (verified 2026-09-23). Keep routing maneuvers separate from translated text and check each new phrase on the avatar.
- Speech: locale hardcoded `pt_BR`, `listenFor: 30s`, `pauseFor: 3s`, `partialResults: true` (`lib/services/speech_service.dart:32-41`). Untestable on desktop/CI — no mic.
- Android perms (`RECORD_AUDIO`, `INTERNET`) already in `android/app/src/main/AndroidManifest.xml`.
- UI copy is pt-BR; keep it pt-BR. Accessibility `Semantics` labels on mic button, text field, gloss, player, status banner are intentional — preserve them.
- `README.md` documents the emulator demo and the simulated/OSRM toggle.

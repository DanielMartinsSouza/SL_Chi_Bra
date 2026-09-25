import 'package:flutter/material.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../models/app_state.dart';
import '../../services/audio_guidance_service.dart';
import '../../services/fake_navigation_provider.dart';
import '../../services/navigation_provider.dart';
import '../../services/osrm_navigation_provider.dart';
import '../widgets/player_widget.dart';
import '../widgets/route_map.dart';

/// Módulo de navegação guiada com acessibilidade em Libras e áudio.
///
/// Exibe o [RouteMap] (flutter_map + OSM) no topo e o player 3D do VLibras
/// ([PlayerWidget]) que sinaliza cada instrução. Cada passo também é
/// narrado em voz via [AudioGuidanceService] (pt-BR) quando o áudio
/// estiver ativado.
class NavigationScreen extends StatefulWidget {
  final AppController Function()? createController;
  final NavigationProvider Function()? createProvider;
  final AudioGuidanceService? audioService;

  const NavigationScreen({
    super.key,
    this.createController,
    this.createProvider,
    this.audioService,
  });

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  late final AppController _controller;
  late final NavigationController _navigation;
  late final AudioGuidanceService _audio;
  bool _ownsAudio = false;
  bool _usingOsrm = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.createController?.call() ?? AppController();
    if (widget.audioService != null) {
      _audio = widget.audioService!;
    } else {
      _audio = AudioGuidanceService();
      _ownsAudio = true;
    }
    _navigation = NavigationController(
      provider: widget.createProvider?.call() ?? FakeNavigationProvider(),
      playInstruction: _playInstruction,
    );
    _controller.addListener(_refresh);
    _navigation.addListener(_refresh);
    _audio.addListener(_refresh);
    _navigation
        .load(FakeNavigationProvider.origin, FakeNavigationProvider.destination)
        .then((_) {
      if (mounted) _navigation.playCurrent();
    });
  }

  /// Sinaliza a instrução no avatar 3D e narra em áudio em paralelo.
  Future<void> _playInstruction(String instruction) async {
    await Future.wait([
      _controller.translateTextAndPlay(instruction),
      _audio.speak(instruction),
    ]);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _switchRoute() async {
    final useOsrm = !_usingOsrm;
    await _navigation.useProvider(
      useOsrm ? OsrmNavigationProvider() : FakeNavigationProvider(),
      FakeNavigationProvider.origin,
      FakeNavigationProvider.destination,
    );
    if (_navigation.error == null) {
      setState(() => _usingOsrm = useOsrm);
      await _navigation.playCurrent();
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _navigation.removeListener(_refresh);
    _audio.removeListener(_refresh);
    _navigation.dispose();
    _controller.dispose();
    if (_ownsAudio) _audio.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isProcessing = _controller.state == AppState.translating ||
        _controller.state == AppState.loadingPlayer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Navegação e Rotas'),
        actions: [
          IconButton(
            tooltip: _audio.enabled ? 'Desativar áudio' : 'Ativar áudio',
            onPressed: () => _audio.enabled = !_audio.enabled,
            icon: Icon(
              _audio.enabled ? Icons.volume_up : Icons.volume_off,
            ),
          ),
          IconButton(
            tooltip: _usingOsrm ? 'Usar rota simulada' : 'Buscar rota OSRM',
            onPressed:
                _navigation.isLoading || _navigation.isAdvancing ? null : _switchRoute,
            icon: Icon(_usingOsrm ? Icons.route : Icons.cloud_download),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final avatarHeight =
                (constraints.maxHeight * 0.29).clamp(110.0, 220.0);
            return Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Semantics(
                      label: 'Mapa da rota de navegação',
                      child: RouteMap(
                        route: _navigation.route,
                        currentStep: _navigation.currentStep,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  PlayerWidget(
                    controller: _controller.playerController,
                    height: avatarHeight,
                  ),
                  _navigationControls(isProcessing),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _navigationControls(bool isProcessing) {
    final step = _navigation.currentStep;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_navigation.error != null)
            Text(
              _navigation.error!,
              style: const TextStyle(color: Colors.red),
            ),
          if (_controller.state == AppState.error)
            Text(
              _controller.errorMessage,
              style: const TextStyle(color: Colors.red),
            ),
          Row(
            children: [
              Expanded(
                child: Semantics(
                  liveRegion: true,
                  label: 'Instrução atual de navegação',
                  value: step?.instruction ?? 'Carregando rota...',
                  child: Text(
                    step?.instruction ?? 'Carregando rota...',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              TextButton(
                onPressed: step == null || isProcessing || _navigation.isAdvancing
                    ? null
                    : _navigation.playCurrent,
                child: const Text('Repetir'),
              ),
              FilledButton(
                onPressed: _navigation.hasNext &&
                        !isProcessing &&
                        !_navigation.isAdvancing
                    ? _navigation.next
                    : null,
                child: const Text('Próximo'),
              ),
            ],
          ),
          if (step != null)
            Text(
              '${_usingOsrm ? 'OSRM' : 'Rota simulada'} • '
              'Passo ${_navigation.currentIndex + 1} de '
              '${_navigation.route!.steps.length}'
              '${_audio.enabled ? ' • Áudio ativado' : ''}',
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../controllers/app_controller.dart';
import '../../controllers/navigation_controller.dart';
import '../../models/app_state.dart';
import '../../services/fake_navigation_provider.dart';
import '../../services/osrm_navigation_provider.dart';
import '../widgets/mic_button.dart';
import '../widgets/player_widget.dart';
import '../widgets/route_map.dart';
import '../widgets/status_banner.dart';

class HomeScreen extends StatefulWidget {
  final AppController Function()? createController;

  const HomeScreen({super.key, this.createController});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AppController _controller;
  late final NavigationController _navigation;
  bool _showTranslator = false;
  bool _usingOsrm = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.createController?.call() ?? AppController();
    _navigation = NavigationController(
      provider: FakeNavigationProvider(),
      playInstruction: _controller.translateTextAndPlay,
    );
    _controller.addListener(_refresh);
    _navigation.addListener(_refresh);
    _navigation
        .load(FakeNavigationProvider.origin, FakeNavigationProvider.destination)
        .then((_) {
      if (mounted) _navigation.playCurrent();
    });
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
    _navigation.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isProcessing = _controller.state == AppState.translating ||
        _controller.state == AppState.loadingPlayer;

    return Scaffold(
      appBar: AppBar(
        title: Text(
            _showTranslator ? 'Tradutor pt-BR para Libras' : 'Rota em Libras'),
        actions: [
          if (!_showTranslator)
            IconButton(
              tooltip: _usingOsrm ? 'Usar rota simulada' : 'Buscar rota OSRM',
              onPressed: _navigation.isLoading || _navigation.isAdvancing
                  ? null
                  : _switchRoute,
              icon: Icon(_usingOsrm ? Icons.route : Icons.cloud_download),
            ),
          TextButton(
            onPressed: () => setState(() => _showTranslator = !_showTranslator),
            child: Text(_showTranslator ? 'Rota' : 'Tradutor'),
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
                    child: _showTranslator
                        ? _translatorControls(isProcessing)
                        : RouteMap(
                            route: _navigation.route,
                            currentStep: _navigation.currentStep,
                          ),
                  ),
                  const SizedBox(height: 8),
                  PlayerWidget(
                    controller: _controller.playerController,
                    height: avatarHeight,
                  ),
                  if (!_showTranslator) _navigationControls(isProcessing),
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
            Text(_navigation.error!, style: const TextStyle(color: Colors.red)),
          if (_controller.state == AppState.error)
            Text(_controller.errorMessage,
                style: const TextStyle(color: Colors.red)),
          Row(
            children: [
              Expanded(
                child: Text(
                  step?.instruction ?? 'Carregando rota...',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              TextButton(
                onPressed:
                    step == null || isProcessing || _navigation.isAdvancing
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
                '${_usingOsrm ? 'OSRM' : 'Rota simulada'} • Passo ${_navigation.currentIndex + 1} de ${_navigation.route!.steps.length}'),
        ],
      ),
    );
  }

  Widget _translatorControls(bool isProcessing) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StatusBanner(
              state: _controller.state, errorMessage: _controller.errorMessage),
          Center(
            child: MicButton(
              state: _controller.state,
              onPressed: _controller.handleMicButtonPress,
            ),
          ),
          Semantics(
            label: 'Campo de texto editável para transcrição de voz',
            child: TextField(
              controller: _controller.textEditingController,
              maxLines: 3,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Texto em Português',
                hintText: 'Toque no microfone para falar ou digite aqui...',
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: isProcessing ? null : _controller.translateAndPlay,
                  icon: const Icon(Icons.translate),
                  label: const Text('Traduzir'),
                ),
              ),
              IconButton.outlined(
                onPressed: _controller.stopPlayer,
                icon: const Icon(Icons.stop),
                tooltip: 'Parar Avatar',
              ),
              IconButton.outlined(
                onPressed: _controller.clearText,
                icon: const Icon(Icons.clear),
                tooltip: 'Limpar texto',
              ),
            ],
          ),
          if (_controller.glossText.isNotEmpty)
            Semantics(
              label: 'Glosa traduzida em formato de texto',
              value: _controller.glossText,
              child: SelectableText('Glosa Gerada: ${_controller.glossText}'),
            ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../controllers/app_controller.dart';
import '../../models/app_state.dart';
import '../widgets/mic_button.dart';
import '../widgets/player_widget.dart';
import '../widgets/status_banner.dart';

/// Tela de tradução livre de texto/voz em pt-BR para Libras.
///
/// Extraída da antiga `HomeScreen` combinada: mantém o [AppController] com
/// o player 3D do VLibras via WebView/WebGL e os controles de voz/texto.
class TranslatorScreen extends StatefulWidget {
  final AppController Function()? createController;

  const TranslatorScreen({super.key, this.createController});

  @override
  State<TranslatorScreen> createState() => _TranslatorScreenState();
}

class _TranslatorScreenState extends State<TranslatorScreen> {
  late final AppController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.createController?.call() ?? AppController();
    _controller.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_refresh);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isProcessing = _controller.state == AppState.translating ||
        _controller.state == AppState.loadingPlayer;

    return Scaffold(
      appBar: AppBar(title: const Text('Tradutor pt-BR para Libras')),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final avatarHeight =
                (constraints.maxHeight * 0.35).clamp(160.0, 320.0);
            return Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          StatusBanner(
                            state: _controller.state,
                            errorMessage: _controller.errorMessage,
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: MicButton(
                              state: _controller.state,
                              onPressed: _controller.handleMicButtonPress,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Semantics(
                            label:
                                'Campo de texto editável para transcrição de voz',
                            child: TextField(
                              controller: _controller.textEditingController,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                labelText: 'Texto em Português',
                                hintText:
                                    'Toque no microfone para falar ou digite aqui...',
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: isProcessing
                                      ? null
                                      : _controller.translateAndPlay,
                                  icon: const Icon(Icons.translate),
                                  label: const Text('Traduzir'),
                                ),
                              ),
                              const SizedBox(width: 8),
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
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Semantics(
                                label: 'Glosa traduzida em formato de texto',
                                value: _controller.glossText,
                                child: SelectableText(
                                  'Glosa Gerada: ${_controller.glossText}',
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  PlayerWidget(
                    controller: _controller.playerController,
                    height: avatarHeight,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

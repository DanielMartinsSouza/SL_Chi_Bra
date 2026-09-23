import 'package:flutter/material.dart';
import '../../controllers/app_controller.dart';
import '../../models/app_state.dart';
import '../widgets/mic_button.dart';
import '../widgets/player_widget.dart';
import '../widgets/status_banner.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AppController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AppController();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isProcessing = _controller.state == AppState.translating ||
        _controller.state == AppState.loadingPlayer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tradutor pt-BR para Libras'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            StatusBanner(
              state: _controller.state,
              errorMessage: _controller.errorMessage,
            ),
            const SizedBox(height: 16),
            PlayerWidget(controller: _controller.playerController),
            const SizedBox(height: 16),
            Center(
              child: MicButton(
                state: _controller.state,
                onPressed: _controller.handleMicButtonPress,
              ),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        isProcessing ? null : _controller.translateAndPlay,
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
            const SizedBox(height: 16),
            if (_controller.glossText.isNotEmpty) ...[
              Text(
                'Glosa Gerada:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Semantics(
                label: 'Glosa traduzida em formato de texto',
                value: _controller.glossText,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SelectableText(
                    _controller.glossText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

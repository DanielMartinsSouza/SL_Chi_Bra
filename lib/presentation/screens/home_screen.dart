import 'package:flutter/material.dart';
import 'navigation_screen.dart';
import 'translator_screen.dart';

/// Tela inicial (hub) do aplicativo.
///
/// Apresenta dois cards principais:
/// 1. Tradutor Livre (VLibras) → [TranslatorScreen] (texto/voz para Libras).
/// 2. Navegação e Rotas → [NavigationScreen] (mapa + avatar 3D + áudio).
class HomeScreen extends StatelessWidget {
  final WidgetBuilder? translatorBuilder;
  final WidgetBuilder? navigationBuilder;

  const HomeScreen({
    super.key,
    this.translatorBuilder,
    this.navigationBuilder,
  });

  void _openTranslator(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: translatorBuilder ??
            (context) => const TranslatorScreen(),
      ),
    );
  }

  void _openNavigation(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            navigationBuilder ?? (context) => const NavigationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rota em Libras')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Escolha um módulo para começar',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _HubCard(
                  semanticsLabel: 'Abrir tradutor livre',
                  icon: Icons.translate,
                  title: 'Tradutor Livre (VLibras)',
                  subtitle: 'Traduza texto e voz em pt-BR para Libras no avatar 3D.',
                  onTap: () => _openTranslator(context),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _HubCard(
                  semanticsLabel: 'Abrir navegação e rotas',
                  icon: Icons.navigation,
                  title: 'Navegação e Rotas',
                  subtitle: 'Mapa com guia em Libras pelo avatar 3D e narração em áudio.',
                  onTap: () => _openNavigation(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HubCard extends StatelessWidget {
  final String semanticsLabel;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HubCard({
    required this.semanticsLabel,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(icon, size: 48),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

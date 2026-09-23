import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../controllers/vlibras_player_controller.dart';

class PlayerWidget extends StatelessWidget {
  final VLibrasPlayerController controller;

  const PlayerWidget({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final webViewController = controller.webViewController;

    return Semantics(
      label: 'Área do Avatar 3D do VLibras',
      child: Container(
        height: 320,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        clipBehavior: Clip.antiAlias,
        child: webViewController == null
            ? const Center(
                child: Text(
                  'Player indisponível neste ambiente.',
                  style: TextStyle(color: Colors.white70),
                ),
              )
            : WebViewWidget(controller: webViewController),
      ),
    );
  }
}

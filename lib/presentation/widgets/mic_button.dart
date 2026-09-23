import 'package:flutter/material.dart';
import '../../models/app_state.dart';

class MicButton extends StatelessWidget {
  final AppState state;
  final VoidCallback onPressed;

  const MicButton({
    super.key,
    required this.state,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isListening = state == AppState.listening;

    return Semantics(
      button: true,
      enabled: state != AppState.translating,
      label:
          isListening ? 'Parar de ouvir voz' : 'Iniciar reconhecimento de voz',
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: isListening
              ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.error.withOpacity(0.5),
                    blurRadius: 16,
                    spreadRadius: 4,
                  )
                ]
              : [],
        ),
        child: IconButton.filled(
          iconSize: 48,
          padding: const EdgeInsets.all(20),
          style: IconButton.styleFrom(
            backgroundColor: isListening
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.primary,
          ),
          onPressed: state == AppState.translating ? null : onPressed,
          icon: Icon(isListening ? Icons.mic_off : Icons.mic),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/app_state.dart';

class StatusBanner extends StatelessWidget {
  final AppState state;
  final String errorMessage;

  const StatusBanner({
    super.key,
    required this.state,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext me) {
    final isError = state == AppState.error;
    final color = isError
        ? Theme.of(me).colorScheme.errorContainer
        : Theme.of(me).colorScheme.primaryContainer;

    final textColor = isError
        ? Theme.of(me).colorScheme.onErrorContainer
        : Theme.of(me).colorScheme.onPrimaryContainer;

    return Semantics(
      liveRegion: true,
      label: 'Status do sistema',
      value: isError ? errorMessage : state.message,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.info_outline,
              color: textColor,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isError ? errorMessage : state.message,
                style: TextStyle(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

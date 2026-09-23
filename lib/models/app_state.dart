enum AppState {
  idle,
  requestingPermission,
  listening,
  processingSpeech,
  readyToTranslate,
  translating,
  loadingPlayer,
  playing,
  stopped,
  error,
}

extension AppStateDescription on AppState {
  String get message {
    switch (this) {
      case AppState.idle:
        return 'Aguardando ação do usuário';
      case AppState.requestingPermission:
        return 'Solicitando permissão de microfone...';
      case AppState.listening:
        return 'Escutando... Fale agora';
      case AppState.processingSpeech:
        return 'Processando fala...';
      case AppState.readyToTranslate:
        return 'Texto pronto para tradução';
      case AppState.translating:
        return 'Traduzindo texto para Libras...';
      case AppState.loadingPlayer:
        return 'Carregando avatar do VLibras...';
      case AppState.playing:
        return 'Sinalizando em Libras';
      case AppState.stopped:
        return 'Sinalização pausada/parada';
      case AppState.error:
        return 'Ocorreu um erro no processo';
    }
  }
}

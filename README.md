# Rota em Libras (protótipo)

Aplicativo Flutter que mostra uma rota e o avatar do VLibras na mesma tela. Cada instrução de navegação em português é enviada à API de tradução do VLibras; a glosa resultante é reproduzida pelo avatar no WebView.

## Executar no Android

```sh
flutter pub get
flutter run -d emulator-5554  # ou use o ID do seu dispositivo em flutter devices
```

É necessária conexão à internet para os mapas, a tradução e o avatar. Não é necessária permissão de localização: origem e destino são coordenadas fixas em Brasília.

- A tela inicial é um hub com dois cards: **Tradutor Livre (VLibras)** abre os controles de voz/texto; **Navegação e Rotas** abre o mapa com o avatar e a narração em áudio (ícone de volume liga/desliga).
- A rota **simulada** aparece ao abrir o módulo de navegação. Aguarde o avatar carregar; o primeiro passo é reproduzido automaticamente (Libras + áudio). Toque **Próximo** para avançar e sinalizar cada instrução; **Repetir** sinaliza o passo atual.
- O ícone de nuvem no topo carrega uma rota real para os mesmos pontos usando o servidor de demonstração do OSRM (`router.project-osrm.org`). O ícone de rota volta à simulação. Ainda não há GPS nem avanço automático.
- **Tradutor** abre os controles existentes de voz/texto; **Rota** volta ao mapa, mantendo o avatar na tela.
- Mapas usam `flutter_map` com os tiles públicos do OpenStreetMap apenas para o protótipo. Para distribuição, configure um provedor de tiles apropriado e mantenha a atribuição.

```sh
flutter test
flutter analyze
```

As instruções de navegação são definidas por manobras em `lib/models/navigation_route.dart`; as fontes de rota implementam `NavigationProvider`. A reprodução continua usando `VLibrasTranslationService` e `VLibrasPlayerController`.

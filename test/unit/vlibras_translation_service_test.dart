import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:china_brasil_sl/services/vlibras_translation_service.dart';

void main() {
  group('VLibrasTranslationService Tests', () {
    test('Deve rejeitar texto vazio com ArgumentError', () async {
      final service = VLibrasTranslationService();
      expect(
          () => service.translateToGloss('   '), throwsA(isA<ArgumentError>()));
    });

    test('Deve interpretar resposta textual pura com sucesso', () async {
      final mockClient = MockClient((request) async {
        return http.Response('OLÁ TUDO_BEM [INTERROGAÇÃO]', 200);
      });
      final service = VLibrasTranslationService(httpClient: mockClient);
      final result = await service.translateToGloss('Olá tudo bem?');

      expect(result, 'OLÁ TUDO_BEM [INTERROGAÇÃO]');
    });

    test('Deve interpretar JSON com a propriedade "traducao"', () async {
      final mockClient = MockClient((request) async {
        return http.Response('{"traducao": "BOM_DIA"}', 200);
      });
      final service = VLibrasTranslationService(httpClient: mockClient);
      final result = await service.translateToGloss('Bom dia');

      expect(result, 'BOM_DIA');
    });

    test('Deve lançar exceção em resposta de erro HTTP (500)', () async {
      final mockClient = MockClient((request) async {
        return http.Response('Internal Error', 500);
      });
      final service = VLibrasTranslationService(httpClient: mockClient);

      expect(
          () => service.translateToGloss('Teste'), throwsA(isA<Exception>()));
    });
  });
}

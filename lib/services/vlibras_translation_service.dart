import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class VLibrasTranslationService {
  static const String _endpoint = 'https://traducao2.vlibras.gov.br/translate';
  static const Duration _timeoutDuration = Duration(seconds: 12);
  final http.Client _httpClient;

  VLibrasTranslationService({http.Client? httpClient})
      : _httpClient = httpClient ?? http.Client();

  Future<String> translateToGloss(String text) async {
    final trimmedText = text.trim();

    if (trimmedText.isEmpty) {
      throw ArgumentError('Digite um texto para traduzir.');
    }

    try {
      final response = await _httpClient
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json, text/plain, */*',
              'User-Agent':
                  'Mozilla/5.0 (Linux; Android 10; Mobile) AppleWebKit/537.36',
              'Origin': 'https://vlibras.gov.br',
              'Referer': 'https://vlibras.gov.br/',
            },
            body: jsonEncode({'text': trimmedText}),
          )
          .timeout(_timeoutDuration);

      if (kDebugMode) {
        print('Status API VLibras: ${response.statusCode}');
        print('Resposta API: ${response.body}');
      }

      if (response.statusCode == 200) {
        return _parseResponse(response.body);
      } else {
        throw Exception(
            'Falha ao conectar com o servidor do VLibras (${response.statusCode}).');
      }
    } on TimeoutException {
      throw Exception('A conexão com a API de tradução expirou.');
    } on http.ClientException {
      throw Exception('Erro de conexão com a internet.');
    } catch (e) {
      if (e is ArgumentError || e is Exception) rethrow;
      throw Exception('Erro ao processar tradução: $e');
    }
  }

  String _parseResponse(String responseBody) {
    if (responseBody.trim().isEmpty) {
      throw const FormatException('A API retornou uma resposta vazia.');
    }

    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is Map<String, dynamic> && decoded.containsKey('traducao')) {
        return decoded['traducao'].toString().trim();
      }
    } catch (_) {
      return responseBody.trim();
    }

    return responseBody.trim();
  }
}

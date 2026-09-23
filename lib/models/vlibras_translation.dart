class VLibrasTranslation {
  final String originalText;
  final String gloss;

  const VLibrasTranslation({
    required this.originalText,
    required this.gloss,
  });

  factory VLibrasTranslation.fromJson(String rawResponse, String originalText) {
    if (rawResponse.trim().isEmpty) {
      throw FormatException('A resposta da API retornou vazia.');
    }
    return VLibrasTranslation(
      originalText: originalText,
      gloss: rawResponse.trim(),
    );
  }
}

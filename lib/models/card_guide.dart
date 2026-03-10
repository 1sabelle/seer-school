class CardGuide {
  final String cardId;
  final String description;
  final String elementMeaning;
  final String? suitMeaning;
  final String? numerologyMeaning;
  final String? courtPersonaMeaning;
  final String uprightMeaning;
  final String reversedMeaning;
  final List<String> reflectionQuestions;

  const CardGuide({
    required this.cardId,
    required this.description,
    required this.elementMeaning,
    this.suitMeaning,
    this.numerologyMeaning,
    this.courtPersonaMeaning,
    required this.uprightMeaning,
    required this.reversedMeaning,
    required this.reflectionQuestions,
  });
}

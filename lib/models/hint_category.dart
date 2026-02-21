enum HintCategory {
  element,
  suit,
  numerology,
  courtPersona,
  theme,
  keywords;

  String get displayLabel {
    switch (this) {
      case HintCategory.element:
        return 'Element';
      case HintCategory.suit:
        return 'Suit';
      case HintCategory.numerology:
        return 'Numerology';
      case HintCategory.courtPersona:
        return 'Court Persona';
      case HintCategory.theme:
        return 'Theme';
      case HintCategory.keywords:
        return 'Keywords';
    }
  }
}

class HintOption {
  final String key;
  final String displayLabel;
  final String? assetPath;

  const HintOption({
    required this.key,
    required this.displayLabel,
    this.assetPath,
  });
}

class HintSlot {
  final HintCategory category;
  final String correctAnswer;
  final List<HintOption> options;
  final String? selectedAnswer;
  final bool isRevealed;

  const HintSlot({
    required this.category,
    required this.correctAnswer,
    required this.options,
    this.selectedAnswer,
    this.isRevealed = false,
  });

  bool get isCorrect => selectedAnswer == correctAnswer;
  bool get hasSelection => selectedAnswer != null;

  HintSlot copyWith({
    String? selectedAnswer,
    bool? isRevealed,
  }) {
    return HintSlot(
      category: category,
      correctAnswer: correctAnswer,
      options: options,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
      isRevealed: isRevealed ?? this.isRevealed,
    );
  }
}

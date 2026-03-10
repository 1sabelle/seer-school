enum HintCategory {
  element,
  suit,
  numerology,
  courtPersona,
  theme,
  keywords,
  arcanaNumber,
  journeyStage;

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
      case HintCategory.arcanaNumber:
        return 'Arcana Number';
      case HintCategory.journeyStage:
        return 'Journey Stage';
    }
  }
}

enum HintType { singleSelect, freeText, multiSelect }

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
  final HintType hintType;
  final String correctAnswer;
  final List<HintOption> options;
  final String? selectedAnswer;
  final bool isRevealed;

  /// For freeText: all accepted answers (lowercase, trimmed).
  final Set<String>? acceptedAnswers;

  /// For multiSelect: the set of correct option keys.
  final Set<String>? correctAnswers;

  /// For multiSelect: the user's selected option keys.
  final Set<String> selectedAnswers;

  const HintSlot({
    required this.category,
    required this.correctAnswer,
    required this.options,
    this.hintType = HintType.singleSelect,
    this.selectedAnswer,
    this.isRevealed = false,
    this.acceptedAnswers,
    this.correctAnswers,
    this.selectedAnswers = const {},
  });

  bool get isCorrect {
    switch (hintType) {
      case HintType.singleSelect:
        return selectedAnswer == correctAnswer;
      case HintType.freeText:
        if (selectedAnswer == null || acceptedAnswers == null) return false;
        return acceptedAnswers!.contains(selectedAnswer!.toLowerCase().trim());
      case HintType.multiSelect:
        if (correctAnswers == null) return false;
        return selectedAnswers.length == correctAnswers!.length &&
            selectedAnswers.containsAll(correctAnswers!);
    }
  }

  bool get hasSelection {
    switch (hintType) {
      case HintType.singleSelect:
      case HintType.freeText:
        return selectedAnswer != null;
      case HintType.multiSelect:
        return selectedAnswers.isNotEmpty;
    }
  }

  HintSlot copyWith({
    String? selectedAnswer,
    bool? isRevealed,
    Set<String>? selectedAnswers,
  }) {
    return HintSlot(
      category: category,
      hintType: hintType,
      correctAnswer: correctAnswer,
      options: options,
      acceptedAnswers: acceptedAnswers,
      correctAnswers: correctAnswers,
      selectedAnswer: selectedAnswer ?? this.selectedAnswer,
      isRevealed: isRevealed ?? this.isRevealed,
      selectedAnswers: selectedAnswers ?? this.selectedAnswers,
    );
  }
}

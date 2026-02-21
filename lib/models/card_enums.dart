enum Arcana { major, minor }

enum Suit {
  wands,
  cups,
  swords,
  pentacles;

  Element get element {
    switch (this) {
      case Suit.wands:
        return Element.fire;
      case Suit.cups:
        return Element.water;
      case Suit.swords:
        return Element.air;
      case Suit.pentacles:
        return Element.earth;
    }
  }

  String get themeKeywords {
    switch (this) {
      case Suit.wands:
        return 'Creativity, Power, Spirit';
      case Suit.cups:
        return 'Emotion, Intuition, Relationships';
      case Suit.swords:
        return 'Intellect, Truth, Conflict';
      case Suit.pentacles:
        return 'Matter, Physicality, Wealth';
    }
  }
}

enum Element {
  fire,
  water,
  air,
  earth;

  String get symbolAssetPath {
    switch (this) {
      case Element.fire:
        return 'assets/symbols/element_fire.svg';
      case Element.water:
        return 'assets/symbols/element_water.svg';
      case Element.air:
        return 'assets/symbols/element_air.svg';
      case Element.earth:
        return 'assets/symbols/element_earth.svg';
    }
  }
}

enum CardNumber {
  ace,
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  nine,
  ten;

  NumerologyKeyword get numerology {
    switch (this) {
      case CardNumber.ace:
        return NumerologyKeyword.potential;
      case CardNumber.two:
        return NumerologyKeyword.routine;
      case CardNumber.three:
        return NumerologyKeyword.embodiment;
      case CardNumber.four:
        return NumerologyKeyword.stillness;
      case CardNumber.five:
        return NumerologyKeyword.challenge;
      case CardNumber.six:
        return NumerologyKeyword.transition;
      case CardNumber.seven:
        return NumerologyKeyword.discernment;
      case CardNumber.eight:
        return NumerologyKeyword.transformation;
      case CardNumber.nine:
        return NumerologyKeyword.fulfillment;
      case CardNumber.ten:
        return NumerologyKeyword.completion;
    }
  }
}

enum CourtRank {
  page,
  knight,
  queen,
  king;

  CourtPersona get persona {
    switch (this) {
      case CourtRank.page:
        return CourtPersona.messenger;
      case CourtRank.knight:
        return CourtPersona.adventurer;
      case CourtRank.queen:
        return CourtPersona.nurturer;
      case CourtRank.king:
        return CourtPersona.leader;
    }
  }
}

enum NumerologyKeyword {
  potential,
  routine,
  embodiment,
  stillness,
  challenge,
  transition,
  discernment,
  transformation,
  fulfillment,
  completion;

  String get displayLabel {
    return name[0].toUpperCase() + name.substring(1);
  }
}

enum CourtPersona {
  messenger,
  adventurer,
  nurturer,
  leader;

  String get displayLabel {
    return name[0].toUpperCase() + name.substring(1);
  }
}

# Seer School

*A gentle study companion for the 78 cards of the tarot.*

<p align="center">
  <img src="https://img.shields.io/badge/flutter-%2302569B.svg?style=flat&logo=flutter&logoColor=white" alt="Flutter">
  <img src="https://img.shields.io/badge/dart-%230175C2.svg?style=flat&logo=dart&logoColor=white" alt="Dart">
  <img src="https://img.shields.io/badge/platform-iOS%20%7C%20Android%20%7C%20Web-lightgrey" alt="Platform">
</p>

---

Draw a card. Study its nature. Guess its element, suit, numerology, and theme. Over time, the cards become familiar friends rather than strangers.

Seer School teaches the Rider-Waite-Smith tarot deck through interactive practice and spaced repetition, wrapped in the warm aesthetic of an old illustrated grimoire.

## What you'll learn

- **Elements** as alchemical symbols, not words -- because memorising the triangle for fire is harder (and more rewarding) than reading "fire"
- **Suits** as thematic keyword groups -- *Creativity, Power, Spirit* instead of just "Wands"
- **Numerology** as abstract concepts -- *Potential*, *Stillness*, *Transformation* -- without numbers attached
- **Court personas** stripped of their titles -- is this the *Messenger* or the *Nurturer*?
- **Themes** through multiple choice, drawing distractors from sibling cards

Nothing is obvious. Everything is memorisation, not recognition.

## Features

- All 78 cards with the original 1909 Pamela Colman Smith illustrations
- Interactive hint slots with animated pickers
- Per-card and per-category statistics that persist across sessions
- Browse the full deck with mastery indicators at a glance
- Practice Weakest mode to focus on what you struggle with
- Filter by suit or arcana type
- Onboarding walkthrough for first-time users
- Parchment-and-serif scholarly design throughout

## Screenshots

*Coming soon*

## Getting started

```bash
flutter pub get
flutter run
```

For web:
```bash
flutter run -d chrome
```

## Tech stack

| | |
|---|---|
| Framework | Flutter |
| State | Riverpod |
| Storage | Hive |
| Routing | go_router |
| Fonts | Cormorant Garamond via Google Fonts |
| SVG | flutter_svg |

## Project structure

```
lib/
  core/           -- theme, colours, constants
  data/           -- 78 card definitions, hint option lists
  models/         -- enums, data classes, Hive adapters
  services/       -- card draw, practice logic, statistics
  providers/      -- Riverpod state management
  screens/
    home/         -- navigation hub
    practice/     -- core study loop
    browse/       -- deck grid + card details
    statistics/   -- progress dashboard
    onboarding/   -- first-launch walkthrough
assets/
  cards/          -- RWS illustrations by suit
  symbols/        -- alchemical element SVGs
```

## Card illustrations

The tarot illustrations are the original 1909 Rider-Waite-Smith artwork by Pamela Colman Smith, in the public domain worldwide.

---

*Built with patience, like learning the cards themselves.*

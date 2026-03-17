# Mood Garden

**"A quiet mirror for your emotions"**

iOS 26 | SwiftUI + SpriteKit | SwiftData

## Overview

Mood Garden is a mood journaling app that transforms daily emotions into a living landscape. Record your mood once a day in under 5 seconds, and the app renders it as a garden element — flowers, moss, rain, fog, wind. Over time, a unique emotional landscape emerges.

Seven moods map to distinct garden elements. The garden does not judge: happy days do not bloom while sad days wilt. Every emotion produces an equally beautiful element. A garden that has experienced many weathers is richer than one with only sunshine.

<!-- screenshots -->

## Requirements

- Xcode 26 with iOS 26 SDK
- [Homebrew](https://brew.sh) (for development tools)

## Getting Started

```bash
git clone https://github.com/focuswave/MoodGarden.git
cd MoodGarden

# Install linter and formatter
brew install swiftlint swift-format

# Set up git pre-commit hook
make setup
```

Open `MoodGarden.xcodeproj` in Xcode and run on an iOS 26 simulator or device.

## Development

```bash
make lint      # Run SwiftLint
make format    # Auto-format with swift-format
make check     # Check both (no modifications)
```

A pre-commit hook auto-formats staged `.swift` files and blocks commits on SwiftLint errors.

## Architecture

MVVM with SwiftUI for screens and SpriteKit for real-time garden rendering.

```
MoodGarden/
├── App/        # Entry point, app state
├── Models/     # SwiftData models, MoodType enum
├── Views/      # SwiftUI screens
├── Garden/     # SpriteKit scene, renderer, element sprites
└── Services/   # Notifications, snapshot rendering
```

See [CLAUDE.md](CLAUDE.md) for detailed technical guidance.

## Documentation

- [Concept Document](docs/mood-garden-concept.md) — Philosophy, design principles, monetization strategy
- [MVP Specification](docs/mood-garden-mvp-spec.md) — Implementation details, data models, SpriteKit specs

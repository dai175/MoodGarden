# Mood Garden

**"A quiet mirror for your emotions"**

iOS 26 | SwiftUI + SpriteKit | SwiftData

## Overview

Mood Garden is a mood journaling app that transforms daily emotions into a living landscape. Record your mood once a day in under 5 seconds, and the app renders it as a garden element — flowers, moss, rain, fog, wind. Over time, a unique emotional landscape emerges.

Seven moods map to distinct garden elements. The garden does not judge: happy days do not bloom while sad days wilt. Every emotion produces an equally beautiful element. A garden that has experienced many weathers is richer than one with only sunshine.

<!-- TODO: Add app screenshots -->

## Features

- **7つのムード** — peaceful, happy, energetic, anxious, sad, angry, tired を 14 種類以上のガーデンエレメント（花、苔、草、蔦、蝶、虹、霧、雨粒など）に変換
- **リアルタイム描画** — SpriteKit による 7×5 グリッドのアニメーション付きガーデン
- **季節オーバーレイ** — 春は桜、夏は蛍、秋は紅葉、冬は雪が庭に重なる
- **月次アーカイブ** — 月替わりで庭がリセットされ、スナップショット画像付きで過去の庭を振り返れる
- **リマインダー通知** — 毎日の記録を忘れないようにやさしく通知
- **ダークテーマ** — 深い緑のダークUI、ミニマルで静かなデザイン

> **Status:** MVP complete — all core features implemented and polished.

## Requirements

- Xcode 26 with iOS 26 SDK
- [Homebrew](https://brew.sh) (for development tools)

## Getting Started

```bash
git clone https://github.com/dai175/MoodGarden.git
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

# Run tests
xcodebuild test -scheme MoodGarden -destination 'platform=iOS Simulator,name=iPhone 17 Pro'
```

A pre-commit hook auto-formats staged `.swift` files and blocks commits on SwiftLint errors.

## Architecture

MVVM with SwiftUI for screens and SpriteKit for real-time garden rendering.

```
MoodGarden/
├── MoodGardenApp.swift  # Entry point
├── App/          # App state
├── Models/       # SwiftData models, MoodType enum
├── ViewModels/   # MVVM view models
├── Views/        # SwiftUI screens
├── Garden/       # SpriteKit: scene, renderer, atmosphere engine, elements, seasonal layers
└── Services/     # Notifications, snapshot rendering
```

See [CLAUDE.md](CLAUDE.md) for detailed technical guidance.

## Documentation

- [Concept Document](docs/mood-garden-concept.md) — Philosophy, design principles, monetization strategy
- [MVP Specification](docs/mood-garden-mvp-spec.md) — Implementation details, data models, SpriteKit specs
- [MVP Implementation Plan](docs/mvp-implementation-plan.md) — Phased implementation approach

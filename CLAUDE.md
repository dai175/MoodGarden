# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MoodGarden is an iOS 26+ app that visualizes daily moods as an evolving garden. Users select one of 7 moods, which maps to a garden element rendered via SpriteKit on a 7x5 grid. Built with SwiftUI + SpriteKit, SwiftData for persistence, MVVM architecture.

## Build & Run

```bash
# Build
xcodebuild -scheme MoodGarden -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run tests (unit + UI)
xcodebuild test -scheme MoodGarden -destination 'platform=iOS Simulator,name=iPhone 16'

# Run a single test
xcodebuild test -scheme MoodGarden -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:MoodGardenTests/TestClassName/testMethodName
```

Requires Xcode 26 with iOS 26 SDK. Deployment target: iOS 26.0. No external package dependencies yet.

## Lint & Format

Code quality and style consistency enforced via SwiftLint (linter) + swift-format (Apple's official formatter).

```bash
# Install tools
brew install swiftlint swift-format

# Set up git pre-commit hook
make setup

# Run linter
make lint

# Auto-format code
make format

# Check both (no modifications)
make check
```

The pre-commit hook auto-formats staged `.swift` files and blocks commits on SwiftLint errors. If tools are not installed, it shows a warning without blocking.

## Tech Stack

- **Language:** Swift 6.1+
- **UI:** SwiftUI (screens) + SpriteKit (garden rendering at 60fps)
- **Data:** SwiftData (local-only, no CloudKit)
- **Tests:** Testing framework (unit), XCTest (UI tests)
- **Architecture:** MVVM

## Architecture

### Planned Structure (per MVP spec)

- `App/` - Entry point, app state
- `Models/` - SwiftData models: `MoodEntry` (date, mood, gardenSeed), `MonthlyGarden` (snapshot), `MoodType` enum (7 moods)
- `Views/` - SwiftUI screens: Garden (home), MoodSelector, Archive, Settings, Onboarding
- `Garden/` - SpriteKit layer: `GardenScene`, `GardenRenderer`, element sprites (moss, flower, rain, fog, wind, grass, leaf), seasonal overlays
- `Services/` - Notification scheduling, snapshot rendering

### Key Concepts

- **MoodType enum:** peaceful, happy, energetic, anxious, sad, angry, tired - each maps to specific garden elements
- **Garden grid:** 7 columns x 5 rows, one cell per day, fills left-to-right
- **Monthly cycle:** Garden resets each month; previous months saved to archive with snapshot images
- **Seasonal layers:** Spring (cherry blossoms), Summer (fireflies), Autumn (falling leaves), Winter (snow)

## Design Guidelines

- **Dark theme only:** Background `#0A1A12` to `#0D2818`, soft white text `#E8E4DC` at 0.8 opacity
- **Accent color:** Teal `#1D9E75`
- **Transitions:** Slow, organic (0.8-1.5s). No bounce, no spring animations, no loading spinners
- **No haptic feedback** - maintain quietness
- **Liquid Glass:** iOS 26 feature - test blending with system UI elements
- **UI elements:** Semi-transparent backgrounds, minimal chrome

## Commit Convention

Conventional Commits format:

```
<type>(<scope>): <description>
```

- **type:** `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `perf`, `ci`
- **scope:** optional, e.g. `garden`, `archive`, `models`, `settings`
- **subject:** lowercase, imperative mood, no period
- **body:** optional. Explain "why" not "what". Blank line after subject. Wrap at 72 chars
- **footer:** `BREAKING CHANGE: <description>` for breaking changes, `Closes #<number>` for issue refs

## Reference Documents

- `docs/mood-garden-concept.md` - Full concept, philosophy, monetization strategy, v2 roadmap
- `docs/mood-garden-mvp-spec.md` - MVP specification with detailed implementation guidance, data models, SpriteKit specs

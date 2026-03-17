# Mood Garden

**"A quiet mirror for your emotions"**

focuswave · Concept Document v1.3 · March 2026
iOS 26 | Swift | Freemium | Widget

---

## 1. Overview

Mood Garden is a mood journaling app that transforms daily emotions into a living landscape. Users record their mood once a day in under 5 seconds, and the app renders it as a garden element — flowers, moss, rain, fog, wind. Over time, a unique emotional landscape emerges. It is not a chart. It is not a game. It is a quiet mirror.

## 2. Core metaphor

Mood Garden is a mirror, not a tool, not a game. A mirror that accumulates time. Today's emotion becomes a landscape. Yesterday's landscape sits beside it. Eventually, a garden forms. Unlike data charts that reduce emotions to numbers, the garden preserves ambiguity — the same way a real landscape holds complexity without explaining it.

## 3. Experience principles

Three principles guide every design decision. They define not just what the app does, but what it refuses to do.

### Principle 1: The garden does not judge

Happy days do not bloom while sad days wilt. Every emotion produces an equally necessary element. Calm days grow moss. Anxious days bring fog. Angry days bring wind. Sad days bring quiet rain. A garden that has experienced many weathers is deeper and richer than one with only sunshine. This is the Zen philosophy at the heart of focuswave: all states are valid.

### Principle 2: Viewing time > operating time

Recording takes 5 seconds. After that, the user simply gazes at their garden. No buttons prompt the next action. No pop-ups suggest exercises. The garden is quietly there. This "time of doing nothing" is the app's essential value. While most wellness apps say "do this next," Mood Garden asks for nothing.

### Principle 3: Insights are self-discovered

The app does not say "You were calm 70% of this month." Instead, the user looks at their monthly garden and notices: "There was a lot of rain in the second half." Landscapes are more ambiguous than data, and that ambiguity leaves room for personal interpretation. AI analysis reports are placed behind the paywall; the free experience centers on looking and feeling.

## 4. Experience flow

### Opening the app

The first thing the user sees is today's garden. Not a button, not a list, not a dashboard. A landscape. They gaze first.

### Recording

A subtle input area at the bottom of the screen. One or two taps to select a mood. The moment they choose, a new element appears in the garden quietly — not with a flashy animation, but like fog slowly clearing. Natural, unhurried.

### Gazing

After recording, the garden simply exists. No scroll prompts. No suggestions. No background music by default — silence is this app's sound. The user closes the app on their own timing.

### Looking back

When the month changes, the previous month's garden is saved as a completed landscape. Lined up side by side, the user can see the seasons of their emotions. Twelve gardens in a row tell the story of a year.

## 5. Mood-to-garden mapping

Each mood produces a garden element that is aesthetically equal — none is "better" than another. The same mood may produce slightly different variations each day, reflecting how nature never repeats itself.

| Mood | Garden element | Visual feel | Season variant |
|------|---------------|-------------|----------------|
| Peaceful / Calm | Moss, still water, soft light | Quiet green tones | Snow-dusted moss in winter |
| Happy / Joyful | Flowers, butterflies, warm breeze | Warm, vibrant accents | Cherry blossoms in spring |
| Energetic | Tall grasses, bright sun, flowing stream | Dynamic, bright | Autumn golden fields |
| Anxious / Uneasy | Fog, tangled vines, low clouds | Diffused, muted | Winter morning mist |
| Sad / Melancholy | Gentle rain, puddles, gray sky | Cool, subdued | Summer evening rain |
| Angry / Frustrated | Strong wind, bent trees, rough waves | Intense movement | Storm in any season |
| Tired / Drained | Fallen leaves, twilight, still air | Dim, heavy | Late autumn dusk |

## 6. Retention design

The greatest risk for a "quiet" app is silent abandonment. Rather than preventing departure, Mood Garden creates reasons to return — pull, not push.

### 1. Traces of absence

Days without a record leave an empty patch in the garden — not wilted, just bare. A natural gap that the human eye wants to fill. No punishment, no streak count. Absence is part of the garden, but presence makes it richer.

### 2. Tomorrow's curiosity

Garden elements don't fully appear at once. Moss starts thin and spreads overnight. Flowers appear as buds and open the next day. "What did yesterday's entry become?" is a small but genuine reason to return.

### 3. Monthly completion

Each month the garden "completes" and is archived as a finished landscape. This gives a goal-less app a sense of closure. As the month progresses, the urge to complete grows. And every month resets — so a missed month never compounds guilt.

### 4. Seasonal resonance

The garden shifts with real-world seasons. Spring brings cherry blossoms, winter brings snow. The same "calm" looks different in April and December. Users anticipate: "What will next month's garden feel like?" After a year, twelve landscapes become a personal calendar.

### 5. Invitation, not reminder

One notification per day, at the user's chosen time. The wording is a question, not a command: "What's the weather in your garden today?" If the user stops opening for 3 days, notification frequency decreases. The app does not chase. When the user returns, no "welcome back" — just the garden, quietly waiting.

Additionally, garden elements include randomized variations. The same "calm" mood may produce a white flower one day and a small pond the next. This is not gamified randomness but reflects how real nature never repeats itself.

## 7. Competitive position

Mood Garden occupies a unique space: deep growth metaphor combined with visual richness and mood tracking. No existing app combines all three.

| App | Approach | Weakness | Mood Garden's edge |
|-----|----------|----------|--------------------|
| Daylio | Emoji + charts + Year in Pixels | Data-driven; feels clinical | Emotion as landscape, not graph |
| Finch | Virtual pet + self-care tasks | Gamified; pop aesthetic; targets younger users | Intrinsic beauty, not extrinsic reward |
| Avocation | Habit tracking + plant growth | Growth = task completion; not about mood | Growth = emotional expression |
| Calm / Headspace | Guided meditation library | Content-heavy; no growth metaphor | Zero content; pure reflection |

## 8. Monetization

Freemium model. The free experience must be complete and beautiful on its own. Premium unlocks depth, not necessity.

### Free tier

- One garden theme (default)
- Full mood recording and viewing
- Monthly garden archive
- Seasonal variations

### Premium tier (estimated: ¥480/month or ¥3,800/year)

- Additional garden themes: Japanese garden, Forest, Seaside, Desert
- One-line memo per mood entry
- Monthly AI insight report (emotional pattern analysis)
- Apple Health integration (sleep + mood correlation)
- Garden export as high-resolution wallpaper image

The paywall's key visual: locked garden themes are shown as beautiful previews behind a frosted overlay. The user sees what they could have — the aesthetic itself is the conversion driver.

## 9. Technical overview

| Component | Detail |
|-----------|--------|
| Platform | iOS 26+ (iPhone) |
| Language | Swift 6.1 / SwiftUI (Liquid Glass compatible) |
| Graphics | SpriteKit or SceneKit for garden rendering |
| Data storage | Local-first (Core Data); optional iCloud sync |
| AI integration | Monthly report generation (API call, premium only) |
| Notifications | Local notifications, user-configured timing |
| Widgets | WidgetKit (iOS 26); interactive intents for large size |
| Health integration | HealthKit (sleep data, premium only) |
| Analytics | Privacy-first: no personal data leaves the device for free tier |

## 10. Widget strategy

Widgets extend the core experience beyond the app. The home screen becomes a window into the garden — the ultimate expression of Principle 2 ("viewing time > operating time"). Widget functionality scales with size: smaller widgets are for gazing, the largest adds recording.

| Size | Display | Interaction | Design intent |
|------|---------|-------------|---------------|
| Small | Today's garden element. If unrecorded, a quiet empty patch. | View only. Tap opens app. | A piece of landscape blending into the home screen. |
| Medium | This week's garden. 7 days of elements side by side. | View only. Tap opens app. | Feel the week's rhythm at a glance. |
| Large | This month's full garden preview. Grows day by day. | View + record. Subtle mood selector appears on unrecorded days. | The garden lives on the home screen. Record without opening the app. |

### Design rationale

This size-based gradient preserves the app's quiet philosophy. Most users will use small or medium widgets, meaning their primary widget experience is purely contemplative. Users who choose the large widget are self-selecting for convenience — they want quick recording, and the large canvas has room for a subtle mood selector without feeling cramped.

The large widget's mood selector appears only on unrecorded days. Once recorded, the selector disappears and the full garden is displayed. This reinforces the principle: the garden is the destination, recording is just the doorway.

Technically, this leverages iOS 26 WidgetKit with interactive intents for the large size. Small and medium widgets use standard timeline-based updates, refreshing when the app writes new mood data to the shared App Group container.

## 11. Marketing synergy

Mood Garden is designed to amplify the existing focuswave SNS strategy. The garden screenshots are inherently shareable content that follows the "don't sell, don't explain" philosophy already proven with Smart Photo Diary on Instagram.

- **Instagram primary:** Monthly garden images as posts. No captions explaining the app — just the landscape and a subtle watermark.
- **X secondary:** Development journey posts in Japanese, showcasing the AI-driven workflow with GitHub Specify + Claude Code.
- **Portfolio synergy:** Smart Photo Diary (visual memory) + Flowease (physical wellbeing) + Mood Garden (emotional wellbeing) = a coherent brand story of "quietly attending to yourself."

## 12. Brand alignment

Mood Garden is not just another focuswave app — it is the most direct expression of the brand's identity. The concentric ripple iconography becomes a living garden. The dark, minimal aesthetic becomes a quiet night garden. The introspective philosophy becomes a design principle: the app asks nothing and offers everything.

## 13. Future vision (v2+)

The following features are deliberately excluded from the MVP to keep the initial experience focused and minimal. They represent natural extensions of the core concept, validated through the design process.

### Garden resident: the frog

A small frog lives quietly in the garden. It does not react to the user. It does not grow. It has no name. It is simply there — sitting by the pond on calm days, sheltering under a leaf when it rains, barely visible through fog on anxious days. The frog is not a character or a pet. It is part of the landscape, like moss or wind. Users will naturally look for it, creating a small moment of discovery each day. This is the Claude Code crab philosophy: zero function, full presence.

Design rules for the frog:
- No name, no profile, no customization
- No reactions to user input (does not smile, wave, or acknowledge)
- Position changes based on weather/mood elements, not user behavior
- Sometimes hard to find (fog days, night scenes) — this is intentional
- Never used as a notification hook ("Your frog misses you" = forbidden)

### Music-influenced gardens

Integration with Apple Music (MusicKit) or Spotify to read listening metadata. The genre, tempo, and mood of music listened to during the day subtly shifts the garden's ambient layer — color temperature, lighting, element density. Jazz adds warmth and night tones. Classical calms the water. Electronic brightens particle effects. The user is never told about this influence; they discover it themselves.

### Photo color absorption

Users can optionally select a photo from their library. The app extracts the dominant color palette (using Vision framework or Core Image) and applies it to the garden's ambient layer. The photo itself is not stored — only its colors are absorbed into the garden. A sunset photo tints the garden orange. A blue ocean shifts toward cool tones. The memory is gone, but its color remains in the landscape.

This must remain clearly distinct from Smart Photo Diary: no photo storage, no diary text, no timeline. Only color extraction.

### Widgets

Three widget sizes as defined in Section 10. Small and medium are view-only; large adds inline mood recording via iOS 26 interactive WidgetKit intents.

### Premium features

- Additional garden themes: Japanese garden, Forest, Seaside, Desert
- One-line memo per mood entry
- Monthly AI insight report (emotional pattern analysis via API)
- Apple Health integration (sleep data + mood correlation)
- Garden export as high-resolution wallpaper image

### Localization

- Japanese (primary market alongside English)
- Potential expansion based on organic demand

### iCloud sync

Cross-device sync for users with multiple iOS devices. Local-first architecture preserved — iCloud is additive, not required.

---

*Confidential — focuswave 2026*

# MoodGarden MVP 実装計画

## Context

MoodGarden は iOS 26+ の気分記録アプリ。日々の気分を庭の要素として SpriteKit で描画する。プロジェクトは Xcode テンプレート状態（`Item` モデル + `ContentView`）で、実アプリコードはゼロ。詳細な MVP 仕様書 (`docs/mood-garden-mvp-spec.md`) は完成済み。

**目標:** 仕様書のアクセプタンスクライテリア 17 項目を満たす MVP を、ボトムアップの 5 フェーズで構築する。

---

## ドキュメント & セッション管理

### 初期セットアップ（フェーズ 0）
1. この計画書を `docs/mvp-implementation-plan.md` としてコミット
2. `git checkout -b feat/mvp-implementation` でブランチ作成

### 会話の進め方
**各フェーズは独立した会話セッションで実行する。** フェーズ間で `/clear` して会話をリセット。

各セッション開始時のプロンプト例:
```
@docs/mvp-implementation-plan.md フェーズ N を実装してください。
```

Claude は計画書を読み、該当フェーズのタスクを順に TDD で実装 → タスクごとにコミット。

### 進捗管理
各フェーズ完了時に計画書の該当フェーズに完了マーク (`[x]`) を付けてコミット。
次セッションで計画書を読めば、どこまで完了したか分かる。

---

## ブランチ戦略 & コミットルール

### ブランチ
- **作業ブランチ:** `feat/mvp-implementation` を `main` から切る
- 全フェーズをこのブランチで作業
- MVP 全体完了後に main へマージ or PR

### コミットタイミング
タスクが完了するごとに 1 コミット。Conventional Commits 形式。

**フェーズ 1:**
1. `feat(models): add MoodType enum with 7 mood types`
2. `feat(models): add MoodEntry SwiftData model`
3. `feat(models): add MonthlyGarden SwiftData model`
4. `feat(app): add AppState for onboarding and app-wide state`
5. `feat(viewmodels): add GardenViewModel with mood recording logic`
6. `refactor(app): replace template code with MoodGarden models`

**フェーズ 2:**
7. `feat(theme): add DesignConstants with color and animation tokens`
8. `feat(views): add GardenView with placeholder grid`
9. `feat(views): add MoodSelectorView and MoodIcon components`
10. `feat(views): add RootView with navigation structure`
11. `refactor(app): replace ContentView with RootView`

**フェーズ 3:**
12. `feat(garden): add GardenGridLayout with coordinate calculation`
13. `feat(garden): add GardenElement protocol and 7 placeholder elements`
14. `feat(garden): add GardenRenderer for MoodEntry to SKNode mapping`
15. `feat(garden): add GardenScene with SpriteKit rendering`
16. `feat(views): integrate SpriteKit into GardenView`

**フェーズ 4:**
17. `feat(services): add NotificationService with scheduling and frequency`
18. `feat(services): add SnapshotService for offscreen garden capture`
19. `feat(views): add OnboardingView with notification setup`
20. `feat(views): add SettingsView with notification and reset options`
21. `feat(views): add ArchiveView and ArchiveDetailView`
22. `feat(app): integrate onboarding, archive, settings, and month transition`

**フェーズ 5:**
23. `feat(garden): add SeasonalLayer with particle effects`
24. `feat(garden): enhance element animations and variations`
25. `feat(garden): add mood recording fog-clearing transition`
26. `perf(garden): migrate to texture atlas for rendering optimization`
27. `style(views): apply final design guidelines across all views`

---

## フェーズ 1: データ基盤 [x]

テンプレートコードを撤去し、MVVM の Model + ViewModel 層を構築。

### タスク

- [x] 1. **MoodType enum** — `MoodGarden/Models/MoodType.swift` (新規)
  - `enum MoodType: String, Codable, CaseIterable` — 7 mood types
  - `displayName`, `color`, `iconName` (SF Symbol) プロパティ
  - テスト: `MoodGardenTests/MoodTypeTests.swift`

- [x] 2. **MoodEntry モデル** — `MoodGarden/Models/MoodEntry.swift` (新規)
  - `@Model final class MoodEntry` — id, date, mood, gardenSeed, createdAt
  - `date` は `Calendar.startOfDay(for:)` で時刻切り捨て
  - テスト: `MoodGardenTests/MoodEntryTests.swift` (インメモリ ModelContainer)

- [x] 3. **MonthlyGarden モデル** — `MoodGarden/Models/MonthlyGarden.swift` (新規)
  - `@Model final class MonthlyGarden` — id, year, month, snapshotImage, completedAt

- [x] 4. **AppState** — `MoodGarden/App/AppState.swift` (新規)
  - `@Observable class AppState` — hasCompletedOnboarding (`@AppStorage`)

- [x] 5. **GardenViewModel** — `MoodGarden/ViewModels/GardenViewModel.swift` (新規)
  - currentMonthEntries, hasTodayEntry, recordMood(), fetchEntries()
  - テスト: `MoodGardenTests/GardenViewModelTests.swift`

- [x] 6. **エントリポイント更新**
  - `MoodGarden/App/MoodGardenApp.swift` (修正) — Schema を MoodEntry.self, MonthlyGarden.self に変更
  - `MoodGarden/Item.swift` (削除)
  - `MoodGarden/ContentView.swift` (修正) — 最小プレースホルダーに一旦変更

### 技術メモ
- `@Model` は暗黙 `@MainActor`。ViewModel も `@MainActor` で統一
- MoodType は `String` RawValue で SwiftData が自動保存
- `#Predicate` で月範囲フィルタ: `date >= monthStart && date < nextMonthStart`

### 検証
- `xcodebuild build` 成功
- ユニットテスト全パス（MoodType, MoodEntry CRUD, ViewModel ロジック）

---

## フェーズ 2: コア UI (SwiftUI) [x]

ムード記録の一連のユーザーフローを SwiftUI で完成。SpriteKit の代わりに仮グリッド表示。

### タスク

- [x] 1. **DesignConstants** — `MoodGarden/Views/Theme/DesignConstants.swift` (新規)
  - 色定数: background `#0A1A12`~`#0D2818`, text `#E8E4DC` (0.8), accent `#1D9E75`
  - アニメーション duration, フォント設定

- [x] 2. **GardenView** — `MoodGarden/Views/GardenView.swift` (新規)
  - フルスクリーン。上部: 月名、右上: 歯車アイコン、下部: MoodSelector
  - フェーズ 2 では LazyVGrid で色付き丸の仮表示

- [x] 3. **MoodSelectorView + MoodIcon** — `MoodGarden/Views/MoodSelectorView.swift`, `MoodGarden/Views/Components/MoodIcon.swift` (新規)
  - 折りたたみ/展開アニメーション (0.8s ease-in-out)
  - hasTodayEntry == true で非表示

- [x] 4. **RootView** — `MoodGarden/Views/RootView.swift` (新規)
  - ナビゲーションルート。`preferredColorScheme(.dark)` 強制
  - Archive: `.sheet`, Settings: `.sheet`

- [x] 5. **エントリポイント更新**
  - `MoodGardenApp.swift` (修正) — ContentView → RootView
  - `ContentView.swift` (削除)

### 技術メモ
- ナビゲーション: `NavigationStack` 不使用（フルスクリーン設計）。sheet/fullScreenCover で遷移
- 1日1回制限: hasTodayEntry で MoodSelector ボタン自体を非表示

### 検証
- アプリ起動 → GardenView 表示
- ムード選択 → グリッドに色付き丸追加
- 同日2回目 → セレクタ非表示
- アプリ再起動 → データ永続化確認

---

## フェーズ 3: SpriteKit 庭 [x]

仮グリッドを SpriteKit レンダリングに置換。プレースホルダー形状で各ムードを表現。

### タスク

- [x] 1. **GardenGridLayout** — `MoodGarden/Garden/GardenGridLayout.swift` (新規)
  - 7列 x 5行。日番号 → (column, row) → CGPoint 変換
  - テスト: `MoodGardenTests/GardenGridLayoutTests.swift`

- [x] 2. **GardenElement protocol** — `MoodGarden/Garden/Elements/GardenElement.swift` (新規)
  - `func createNode(seed: Int, cellSize: CGSize) -> SKNode`

- [x] 3. **7 Elements** (各 新規) — `MoodGarden/Garden/Elements/`
  - Moss (peaceful/緑楕円), Flower (happy/ピンク円), Grass (energetic/緑三角),
  - Fog (anxious/灰色半透明), Rain (sad/青縦線), Wind (angry/斜線), Leaf (tired/茶楕円)
  - seed による 3-5 バリエーション (決定的ランダム)

- [x] 4. **GardenRenderer** — `MoodGarden/Garden/GardenRenderer.swift` (新規)
  - `[MoodEntry]` → SKNode 配列。Element ファクトリ呼び出し
  - テスト: `MoodGardenTests/GardenRendererTests.swift`

- [x] 5. **GardenScene** — `MoodGarden/Garden/GardenScene.swift` (新規)
  - `SKScene` サブクラス。configure(with:), addEntry(_:animated:)
  - 背景色 `#0A1A12`、scaleMode `.resizeFill`

- [x] 6. **GardenView SpriteKit 統合** — `MoodGarden/Views/GardenView.swift` (修正)
  - 仮グリッド → `SpriteView(scene:)` に置換
  - `@Query` の変更を GardenScene に反映

### 技術メモ
- `@preconcurrency import SpriteKit` が必要な場合あり
- SpriteKit 層はデータモデルに依存しない純粋描画レイヤーとして設計
- seed ベースのランダム化: `GKMersenneTwisterRandomSource(seed:)` 使用
- フェーズ 3 は SKShapeNode で速度優先。フェーズ 5 で SKSpriteNode に最適化

### 検証
- 庭が SpriteKit で表示される
- ムード記録 → 対応する色/形がグリッド正位置に出現
- 7 種全てで異なる形状
- 同ムード・異 seed で異なるバリエーション
- 60fps 確認 (Instruments)

---

## フェーズ 4: 補助機能 [ ]

Archive, Settings, Onboarding, 通知, スナップショットを実装。

### タスク

- [ ] 1. **NotificationService** — `MoodGarden/Services/NotificationService.swift` (新規)
  - `actor` で実装。許可リクエスト、デイリースケジュール、メッセージ 4 種ローテーション
  - 頻度自動減少: 3日未記録→隔日、7日→週2回
  - テスト: `MoodGardenTests/NotificationServiceTests.swift`

- [ ] 2. **SnapshotService** — `MoodGarden/Services/SnapshotService.swift` (新規)
  - `@MainActor`。オフスクリーン SKView → PNG Data 生成
  - テスト: `MoodGardenTests/SnapshotServiceTests.swift`

- [ ] 3. **OnboardingView** — `MoodGarden/Views/OnboardingView.swift` (新規)
  - `TabView(.page)` 2-3 ページ。最終ページで通知時間設定 + 許可リクエスト

- [ ] 4. **SettingsView + ViewModel** — `MoodGarden/Views/SettingsView.swift`, `MoodGarden/ViewModels/SettingsViewModel.swift` (新規)
  - 通知時間 DatePicker, オン/オフ Toggle, About, データリセット (confirmationDialog)

- [ ] 5. **ArchiveView + ViewModel** — `MoodGarden/Views/ArchiveView.swift`, `MoodGarden/ViewModels/ArchiveViewModel.swift` (新規)
  - 2列グリッド、月別サムネイル、"In progress" ラベル
  - テスト: `MoodGardenTests/ArchiveViewModelTests.swift`

- [ ] 6. **ArchiveDetailView** — `MoodGarden/Views/ArchiveDetailView.swift` (新規)
  - 過去月をフルスクリーン SpriteKit で再表示（読み取り専用）

- [ ] 7. **統合** — RootView (修正), GardenView (修正), MoodGardenApp.swift (修正)
  - オンボーディング分岐、Archive/Settings への遷移、月遷移スナップショット

### 技術メモ
- 月遷移検出: `scenePhase == .active` 時に `lastActiveMonth` (UserDefaults) と比較
- Liquid Glass: Settings/Archive の Form/List は iOS 26 で自動適用
- オフスクリーンレンダリング: `SKView.texture(from:)` → UIImage → PNG Data

### 検証
- オンボーディング: 初回のみ表示
- 通知: 設定時刻に到着
- Archive: 過去月表示、タップで詳細
- Settings: 通知変更、データリセット
- 月遷移: スナップショット自動生成

---

## フェーズ 5: ポリッシュ [ ]

アニメーション、季節レイヤー、デザイン仕上げ、パフォーマンス最適化。

### タスク

- [ ] 1. **SeasonalLayer** — `MoodGarden/Garden/SeasonalLayer.swift` (新規)
  - 春 (桜), 夏 (蛍), 秋 (落ち葉), 冬 (雪) — SKEmitterNode
  - 色補正レイヤー

- [ ] 2. **Element アニメーション強化** — `MoodGarden/Garden/Elements/*.swift` (全修正)
  - アンビエントアニメーション (SKAction): 揺れ、ドリフト、シマー、雨、霧
  - 3-5 バリエーションの視覚的差異を強化

- [ ] 3. **GardenScene トランジション** — GardenScene.swift (修正)
  - ムード記録時の「霧が晴れる」演出 (0.8-1.2s)
  - SeasonalLayer 統合

- [ ] 4. **テクスチャアトラス移行** — `MoodGarden/Resources/GardenTextures.atlas/` (新規)
  - SKShapeNode → SKSpriteNode で描画パフォーマンス向上
  - ノード数 500 以下、60fps 維持

- [ ] 5. **UI デザイン仕上げ** — 全 Views (修正)
  - 色・フォント・トランジション統一。Liquid Glass との調和確認

### 検証
- 全 7 ムードのアニメーションが自然に動作
- 季節レイヤーが月に応じて変化 (3月 = 春)
- Instruments: 60fps + メモリリークなし
- **MVP アクセプタンスクライテリア 17 項目の全数チェック**

---

## 全体検証 (End-to-End)

```bash
# ビルド
xcodebuild -scheme MoodGarden -destination 'platform=iOS Simulator,name=iPhone 16' build

# テスト
xcodebuild test -scheme MoodGarden -destination 'platform=iOS Simulator,name=iPhone 16'
```

### アクセプタンスクライテリア (docs/mood-garden-mvp-spec.md より)
1. 初回起動で空の庭が表示される
2. ムード選択で庭要素がアニメーション付きで出現
3. 1日1回のみ記録可能
4. 月内で要素が蓄積される
5. 同ムード・別日で異なる見た目
6. アンビエントアニメーション
7. 季節変化
8. 月別アーカイブグリッド
9. 過去月フルスクリーン表示
10. 月初にスナップショット自動生成
11. 通知がローテーションテキストで到着
12. 不活動時の通知頻度自動減少
13. オンボーディング初回のみ
14. 通知設定変更可能
15. 60fps on iPhone 12+
16. 完全オフライン動作
17. ダークテーマのみ

---

## 実装開始手順

### フェーズ 0（初回のみ）
1. この計画書を `docs/mvp-implementation-plan.md` にコピーしてコミット
2. `git checkout -b feat/mvp-implementation` でブランチ作成

### 各フェーズの開始
1. `/clear` で会話リセット
2. `@docs/mvp-implementation-plan.md フェーズ N を実装してください` で開始
3. 各タスク完了時に Conventional Commits でコミット
4. フェーズ完了時にビルド + テスト全パスを確認
5. 計画書のチェックボックスを `[x]` に更新してコミット
6. 次フェーズへ

import SpriteKit
import SwiftUI

struct GardenView: View {
    @Environment(GardenViewModel.self) private var viewModel
    @Environment(AppState.self) private var appState
    @Binding var showArchive: Bool
    @Binding var showSettings: Bool

    @State private var gardenScene = GardenScene()

    private var currentSeason: Season {
        Season.from(month: Calendar.current.component(.month, from: Date()))
    }

    var body: some View {
        ZStack {
            gardenSpriteView
                .ignoresSafeArea()

            VStack {
                monthHeaderView
                Spacer()
                moodSelectorSection
            }
            .padding()
        }
        .onAppear {
            updateScene()
        }
        .onChange(of: viewModel.currentMonthEntries.count) { oldCount, newCount in
            if newCount == oldCount + 1, let last = viewModel.currentMonthEntries.last {
                let newState = AtmosphereEngine.analyze(
                    entries: viewModel.currentMonthEntries, season: currentSeason
                )
                let newSpecs = newState.elementManifest.filter { $0.entryID == last.id }
                gardenScene.performTransition(
                    mood: last.mood,
                    totalRecords: appState.totalRecordCount,
                    newSpecs: newSpecs
                )
            } else {
                updateScene()
            }
        }
    }

    private var monthHeaderView: some View {
        HStack {
            Button {
                showArchive = true
            } label: {
                Text(monthName)
                    .font(DesignConstants.Typography.monthTitle)
                    .foregroundStyle(DesignConstants.Colors.textSubdued)
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 16))
                    .foregroundStyle(DesignConstants.Colors.textSubdued)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Settings")
        }
    }

    private var gardenSpriteView: some View {
        SpriteView(scene: gardenScene)
    }

    private var moodSelectorSection: some View {
        Group {
            if !viewModel.hasTodayEntry {
                MoodSelectorView()
            }
        }
        .frame(height: 60)
    }

    private func updateScene() {
        let state = AtmosphereEngine.analyze(
            entries: viewModel.currentMonthEntries, season: currentSeason
        )
        gardenScene.configure(with: state)
        let month = Calendar.current.component(.month, from: Date())
        gardenScene.configureSeason(month: month)
    }

    private static let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        formatter.locale = Locale.current
        return formatter
    }()

    private var monthName: String {
        Self.monthFormatter.string(from: Date())
    }
}

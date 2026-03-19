import SpriteKit
import SwiftUI

struct GardenView: View {
    @Environment(GardenViewModel.self) private var viewModel
    @Binding var showArchive: Bool
    @Binding var showSettings: Bool

    @State private var gardenScene = GardenScene()

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [DesignConstants.Colors.backgroundPrimary, DesignConstants.Colors.backgroundSecondary],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack {
                monthHeaderView
                Spacer()
                gardenSpriteView
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
                gardenScene.addEntry(makeElementData(from: last), animated: true)
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
            .aspectRatio(
                CGFloat(DesignConstants.Layout.gridColumns) / CGFloat(DesignConstants.Layout.gridRows),
                contentMode: .fit
            )
            .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Layout.cornerRadius))
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
        let entries = viewModel.currentMonthEntries.map(makeElementData)
        gardenScene.configure(with: entries)
        let month = Calendar.current.component(.month, from: Date())
        gardenScene.configureSeason(month: month)
    }

    private func makeElementData(from entry: MoodEntry) -> GardenElementData {
        let day = Calendar.current.component(.day, from: entry.date)
        return GardenElementData(day: day, mood: entry.mood, seed: entry.gardenSeed)
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

import SwiftUI

struct GardenView: View {
    @Environment(GardenViewModel.self) private var viewModel
    @Binding var showArchive: Bool
    @Binding var showSettings: Bool

    private let columns = Array(
        repeating: GridItem(.flexible(), spacing: DesignConstants.Layout.cellSpacing),
        count: DesignConstants.Layout.gridColumns
    )

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
                gardenGridView
                Spacer()
                moodSelectorSection
            }
            .padding()
        }
        .onAppear {
            viewModel.fetchEntries()
        }
    }

    private var monthHeaderView: some View {
        HStack {
            Button {
                showArchive = true
            } label: {
                Text(monthName)
                    .font(DesignConstants.Typography.monthTitle)
                    .foregroundStyle(
                        DesignConstants.Colors.textPrimary.opacity(DesignConstants.Colors.textOpacity)
                    )
            }
            .buttonStyle(.plain)

            Spacer()

            Button {
                showSettings = true
            } label: {
                Image(systemName: "gearshape")
                    .font(.system(size: 16))
                    .foregroundStyle(
                        DesignConstants.Colors.textPrimary.opacity(DesignConstants.Colors.textOpacity)
                    )
            }
            .buttonStyle(.plain)
        }
    }

    private var gardenGridView: some View {
        LazyVGrid(columns: columns, spacing: DesignConstants.Layout.cellSpacing) {
            let totalCells = DesignConstants.Layout.gridColumns * DesignConstants.Layout.gridRows
            ForEach(1...totalCells, id: \.self) { day in
                gardenCell(for: day)
            }
        }
    }

    private func gardenCell(for day: Int) -> some View {
        let entry = entryForDay(day)
        return RoundedRectangle(cornerRadius: DesignConstants.Layout.cornerRadius)
            .fill(
                entry != nil
                    ? entry!.mood.color.opacity(0.6)
                    : DesignConstants.Colors.backgroundSecondary.opacity(DesignConstants.Layout.glassOpacity)
            )
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                if let entry {
                    MoodIcon(mood: entry.mood, size: 24)
                }
            }
    }

    private var moodSelectorSection: some View {
        Group {
            if !viewModel.hasTodayEntry {
                MoodSelectorView()
            }
        }
        .frame(height: 60)
    }

    private func entryForDay(_ day: Int) -> MoodEntry? {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: Date())
        guard
            let dayDate = calendar.date(
                from: DateComponents(
                    year: components.year, month: components.month, day: day
                ))
        else {
            return nil
        }
        let startOfDay = calendar.startOfDay(for: dayDate)
        return viewModel.currentMonthEntries.first { $0.date == startOfDay }
    }

    private var monthName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM"
        return formatter.string(from: Date())
    }
}

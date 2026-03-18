import Foundation
import SwiftData

@Observable
final class ArchiveViewModel {
    struct MonthInfo: Identifiable, Hashable {
        let id: String
        let year: Int
        let month: Int
        let garden: MonthlyGarden?
        let isCurrent: Bool

        var displayName: String {
            let components = DateComponents(year: year, month: month)
            guard let date = Calendar.current.date(from: components) else { return "" }
            return Self.formatter.string(from: date)
        }

        private static let formatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            formatter.locale = Locale.current
            return formatter
        }()

        func hash(into hasher: inout Hasher) { hasher.combine(id) }
        static func == (lhs: MonthInfo, rhs: MonthInfo) -> Bool { lhs.id == rhs.id }
    }

    private(set) var months: [MonthInfo] = []
    private var modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchData() {
        let descriptor = FetchDescriptor<MonthlyGarden>(
            sortBy: [
                SortDescriptor(\.year, order: .reverse),
                SortDescriptor(\.month, order: .reverse),
            ]
        )
        let gardens = (try? modelContext.fetch(descriptor)) ?? []

        var result: [MonthInfo] = []

        let calendar = Calendar.current
        let now = Date()
        let currentYear = calendar.component(.year, from: now)
        let currentMonth = calendar.component(.month, from: now)

        result.append(
            MonthInfo(
                id: "\(currentYear)-\(currentMonth)",
                year: currentYear,
                month: currentMonth,
                garden: nil,
                isCurrent: true
            ))

        for garden in gardens {
            if garden.year == currentYear && garden.month == currentMonth { continue }
            result.append(
                MonthInfo(
                    id: "\(garden.year)-\(garden.month)",
                    year: garden.year,
                    month: garden.month,
                    garden: garden,
                    isCurrent: false
                ))
        }

        months = result
    }

    func entriesForMonth(year: Int, month: Int) -> [MoodEntry] {
        let calendar = Calendar.current
        guard
            let monthStart = calendar.date(from: DateComponents(year: year, month: month)),
            let nextMonthStart = calendar.date(byAdding: .month, value: 1, to: monthStart)
        else { return [] }

        let descriptor = FetchDescriptor<MoodEntry>(
            predicate: #Predicate { $0.date >= monthStart && $0.date < nextMonthStart },
            sortBy: [SortDescriptor(\.date)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }
}

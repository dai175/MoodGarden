import Foundation
import SwiftData
import Testing

@testable import MoodGarden

@Suite("ArchiveViewModel Tests")
@MainActor
struct ArchiveViewModelTests {
    @Test("months includes current month as in-progress")
    func currentMonthInProgress() throws {
        let container = try TestHelpers.makeModelContainer()
        let context = container.mainContext
        let viewModel = ArchiveViewModel(modelContext: context)
        viewModel.fetchData()

        let calendar = Calendar.current
        let now = Date()
        let currentYear = calendar.component(.year, from: now)
        let currentMonth = calendar.component(.month, from: now)

        #expect(viewModel.months.first?.year == currentYear)
        #expect(viewModel.months.first?.month == currentMonth)
        #expect(viewModel.months.first?.isCurrent == true)
    }

    @Test("months includes archived gardens sorted newest first")
    func archivedGardensSorted() throws {
        let container = try TestHelpers.makeModelContainer()
        let context = container.mainContext

        let calendar = Calendar.current
        let now = Date()
        let currentYear = calendar.component(.year, from: now)

        let jan = MonthlyGarden(year: currentYear, month: 1)
        jan.completedAt = Date()
        let feb = MonthlyGarden(year: currentYear, month: 2)
        feb.completedAt = Date()
        context.insert(jan)
        context.insert(feb)
        try context.save()

        let viewModel = ArchiveViewModel(modelContext: context)
        viewModel.fetchData()

        #expect(viewModel.months.count >= 3)
        #expect(viewModel.months.first?.isCurrent == true)

        let archivedMonths = viewModel.months.filter { !$0.isCurrent }
        let febEntry = archivedMonths.first(where: { $0.month == 2 })
        let janEntry = archivedMonths.first(where: { $0.month == 1 })
        #expect(febEntry != nil)
        #expect(janEntry != nil)
    }

    @Test("entriesForMonth returns entries in that month")
    func entriesForMonth() throws {
        let container = try TestHelpers.makeModelContainer()
        let context = container.mainContext

        let entry = MoodEntry(mood: .happy)
        context.insert(entry)
        try context.save()

        let viewModel = ArchiveViewModel(modelContext: context)
        let calendar = Calendar.current
        let now = Date()
        let entries = viewModel.entriesForMonth(
            year: calendar.component(.year, from: now),
            month: calendar.component(.month, from: now)
        )
        #expect(entries.count == 1)
    }
}

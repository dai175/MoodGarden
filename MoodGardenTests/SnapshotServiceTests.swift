import Foundation
import SwiftData
import Testing

@testable import MoodGarden

@Suite("SnapshotService Tests")
@MainActor
struct SnapshotServiceTests {
    @Test("performMonthTransition skips when no entries")
    func noEntriesSkips() throws {
        let container = try TestHelpers.makeModelContainer()
        let context = container.mainContext
        let service = SnapshotService()

        let result = service.performMonthTransition(
            modelContext: context,
            previousYear: 2026,
            previousMonth: 2,
            entries: []
        )
        #expect(result == false)
    }

    @Test("performMonthTransition creates MonthlyGarden with snapshot")
    func createsGarden() throws {
        let container = try TestHelpers.makeModelContainer()
        let context = container.mainContext
        let service = SnapshotService()

        let entry = MoodEntry(mood: .happy)
        context.insert(entry)
        try context.save()

        let result = service.performMonthTransition(
            modelContext: context,
            previousYear: 2026,
            previousMonth: 2,
            entries: [entry]
        )
        #expect(result == true)

        let descriptor = FetchDescriptor<MonthlyGarden>()
        let gardens = try context.fetch(descriptor)
        #expect(gardens.count == 1)
        #expect(gardens.first?.year == 2026)
        #expect(gardens.first?.month == 2)
        #expect(gardens.first?.completedAt != nil)
    }

    @Test("performMonthTransition skips if garden already exists")
    func skipsDuplicate() throws {
        let container = try TestHelpers.makeModelContainer()
        let context = container.mainContext
        let service = SnapshotService()

        let existing = MonthlyGarden(year: 2026, month: 2)
        existing.completedAt = Date()
        context.insert(existing)
        try context.save()

        let entry = MoodEntry(mood: .sad)
        context.insert(entry)
        try context.save()

        let result = service.performMonthTransition(
            modelContext: context,
            previousYear: 2026,
            previousMonth: 2,
            entries: [entry]
        )
        #expect(result == false)

        let descriptor = FetchDescriptor<MonthlyGarden>()
        let gardens = try context.fetch(descriptor)
        #expect(gardens.count == 1)
    }
}

import SwiftData
import Testing

@testable import MoodGarden

@Suite("SettingsViewModel Tests")
@MainActor
struct SettingsViewModelTests {
    @Test("resetAllData deletes all MoodEntries and MonthlyGardens")
    func resetDeletesAll() throws {
        let container = try TestHelpers.makeModelContainer()
        let context = container.mainContext

        context.insert(MoodEntry(mood: .happy))
        context.insert(MoodEntry(mood: .sad))
        context.insert(MonthlyGarden(year: 2026, month: 1))
        try context.save()

        let viewModel = SettingsViewModel(
            notificationService: NotificationService(),
            modelContext: context
        )
        let result = viewModel.resetAllData()
        #expect(result == true)

        let entries = try context.fetch(FetchDescriptor<MoodEntry>())
        let gardens = try context.fetch(FetchDescriptor<MonthlyGarden>())
        #expect(entries.isEmpty)
        #expect(gardens.isEmpty)
    }
}

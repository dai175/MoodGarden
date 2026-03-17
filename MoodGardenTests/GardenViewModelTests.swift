import Foundation
import SwiftData
import Testing

@testable import MoodGarden

@MainActor
struct GardenViewModelTests {

    @Test
    func initiallyEmptyEntries() throws {
        let container = try ModelContainer(
            for: MoodEntry.self, MonthlyGarden.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let viewModel = GardenViewModel(modelContext: container.mainContext)
        viewModel.fetchEntries()
        #expect(viewModel.currentMonthEntries.isEmpty)
    }

    @Test
    func recordMoodIncreasesEntries() throws {
        let container = try ModelContainer(
            for: MoodEntry.self, MonthlyGarden.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let viewModel = GardenViewModel(modelContext: container.mainContext)
        viewModel.fetchEntries()
        #expect(viewModel.currentMonthEntries.isEmpty)

        viewModel.recordMood(.happy)
        #expect(viewModel.currentMonthEntries.count == 1)
        #expect(viewModel.currentMonthEntries.first?.mood == .happy)
    }

    @Test
    func hasTodayEntryAfterRecording() throws {
        let container = try ModelContainer(
            for: MoodEntry.self, MonthlyGarden.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let viewModel = GardenViewModel(modelContext: container.mainContext)
        #expect(!viewModel.hasTodayEntry)

        viewModel.recordMood(.peaceful)
        #expect(viewModel.hasTodayEntry)
    }

    @Test
    func recordTwiceSameDayResultsInTwoEntries() throws {
        let container = try ModelContainer(
            for: MoodEntry.self, MonthlyGarden.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let viewModel = GardenViewModel(modelContext: container.mainContext)
        viewModel.recordMood(.happy)
        viewModel.recordMood(.sad)
        #expect(viewModel.currentMonthEntries.count == 2)
        #expect(viewModel.hasTodayEntry)
    }

    @Test
    func fetchEntriesOnlyReturnsCurrentMonth() throws {
        let container = try ModelContainer(
            for: MoodEntry.self, MonthlyGarden.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext
        let viewModel = GardenViewModel(modelContext: context)

        viewModel.recordMood(.energetic)

        let calendar = Calendar.current
        let lastMonth = calendar.date(byAdding: .month, value: -1, to: Date())!
        let oldEntry = MoodEntry(mood: .tired, date: lastMonth)
        context.insert(oldEntry)

        viewModel.fetchEntries()
        #expect(viewModel.currentMonthEntries.count == 1)
        #expect(viewModel.currentMonthEntries.first?.mood == .energetic)
    }
}

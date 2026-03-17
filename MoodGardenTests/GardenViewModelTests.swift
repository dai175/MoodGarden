//
//  GardenViewModelTests.swift
//  MoodGardenTests
//
//  Created by Daisuke Ooba on 2026/03/17.
//

import Foundation
import SwiftData
import Testing

@testable import MoodGarden

@MainActor
struct GardenViewModelTests {
    private func makeViewModel() throws -> GardenViewModel {
        let container = try ModelContainer(
            for: MoodEntry.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext
        return GardenViewModel(modelContext: context)
    }

    @Test
    func initiallyEmptyEntries() throws {
        let viewModel = try makeViewModel()
        viewModel.fetchEntries()
        #expect(viewModel.currentMonthEntries.isEmpty)
    }

    @Test
    func recordMoodIncreasesEntries() throws {
        let viewModel = try makeViewModel()
        viewModel.fetchEntries()
        #expect(viewModel.currentMonthEntries.isEmpty)

        viewModel.recordMood(.happy)
        #expect(viewModel.currentMonthEntries.count == 1)
        #expect(viewModel.currentMonthEntries.first?.mood == .happy)
    }

    @Test
    func hasTodayEntryAfterRecording() throws {
        let viewModel = try makeViewModel()
        #expect(!viewModel.hasTodayEntry)

        viewModel.recordMood(.peaceful)
        #expect(viewModel.hasTodayEntry)
    }

    @Test
    func recordTwiceSameDayResultsInTwoEntries() throws {
        let viewModel = try makeViewModel()
        viewModel.recordMood(.happy)
        viewModel.recordMood(.sad)
        #expect(viewModel.currentMonthEntries.count == 2)
        #expect(viewModel.hasTodayEntry)
    }

    @Test
    func fetchEntriesOnlyReturnsCurrentMonth() throws {
        let container = try ModelContainer(
            for: MoodEntry.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext
        let viewModel = GardenViewModel(modelContext: context)

        // Insert an entry for the current month
        viewModel.recordMood(.energetic)

        // Insert an entry for a previous month directly into the context
        let calendar = Calendar.current
        let lastMonth = calendar.date(byAdding: .month, value: -1, to: Date())!
        let oldEntry = MoodEntry(mood: .tired, date: lastMonth)
        context.insert(oldEntry)

        viewModel.fetchEntries()
        #expect(viewModel.currentMonthEntries.count == 1)
        #expect(viewModel.currentMonthEntries.first?.mood == .energetic)
    }
}

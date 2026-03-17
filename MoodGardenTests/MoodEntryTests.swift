//
//  MoodEntryTests.swift
//  MoodGardenTests
//
//  Created by Daisuke Ooba on 2026/03/17.
//

import Foundation
import SwiftData
import Testing

@testable import MoodGarden

struct MoodEntryTests {

    @Test func createMoodEntryHasExpectedProperties() {
        let entry = MoodEntry(mood: .happy)
        #expect(entry.mood == .happy)
        #expect(entry.gardenSeed >= 0)
        #expect(entry.gardenSeed <= Int.max)
    }

    @Test func dateIsNormalizedToStartOfDay() {
        // Create a date with a specific time component
        var components = DateComponents()
        components.year = 2026
        components.month = 3
        components.day = 17
        components.hour = 14
        components.minute = 30
        components.second = 45
        let dateWithTime = Calendar.current.date(from: components)!

        let entry = MoodEntry(mood: .peaceful, date: dateWithTime)

        let startOfDay = Calendar.current.startOfDay(for: dateWithTime)
        #expect(entry.date == startOfDay)

        // Verify time components are zeroed out
        let resultComponents = Calendar.current.dateComponents([.hour, .minute, .second], from: entry.date)
        #expect(resultComponents.hour == 0)
        #expect(resultComponents.minute == 0)
        #expect(resultComponents.second == 0)
    }

    @Test func idIsUniqueForEachEntry() {
        let entry1 = MoodEntry(mood: .happy)
        let entry2 = MoodEntry(mood: .happy)
        #expect(entry1.id != entry2.id)
    }

    @Test func gardenSeedVariesBetweenEntries() {
        // With a sufficiently large range, two random seeds are almost certainly different
        var seeds = Set<Int>()
        for _ in 0..<10 {
            let entry = MoodEntry(mood: .tired)
            seeds.insert(entry.gardenSeed)
        }
        // With 10 entries over a range of Int.max, we expect multiple unique seeds
        #expect(seeds.count > 1)
    }

    @MainActor
    @Test func crudWithInMemoryModelContainer() throws {
        let container = try ModelContainer(
            for: MoodEntry.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext

        // Create
        let entry = MoodEntry(mood: .energetic)
        context.insert(entry)
        try context.save()

        // Read
        let descriptor = FetchDescriptor<MoodEntry>()
        let fetched = try context.fetch(descriptor)
        #expect(fetched.count == 1)
        #expect(fetched[0].mood == .energetic)

        // Update
        fetched[0].mood = .sad
        try context.save()
        let updated = try context.fetch(descriptor)
        #expect(updated[0].mood == .sad)

        // Delete
        context.delete(updated[0])
        try context.save()
        let afterDelete = try context.fetch(descriptor)
        #expect(afterDelete.isEmpty)
    }

    @MainActor
    @Test func multipleEntriesPersistedCorrectly() throws {
        let container = try ModelContainer(
            for: MoodEntry.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext

        let moods: [MoodType] = [.peaceful, .happy, .energetic, .anxious, .sad, .angry, .tired]
        for mood in moods {
            let entry = MoodEntry(mood: mood)
            context.insert(entry)
        }
        try context.save()

        let descriptor = FetchDescriptor<MoodEntry>()
        let fetched = try context.fetch(descriptor)
        #expect(fetched.count == 7)
    }

    @MainActor
    @Test func entryDateStoredAndFetchedCorrectly() throws {
        let container = try ModelContainer(
            for: MoodEntry.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext

        var components = DateComponents()
        components.year = 2026
        components.month = 1
        components.day = 15
        let specificDate = Calendar.current.date(from: components)!

        let entry = MoodEntry(mood: .peaceful, date: specificDate)
        context.insert(entry)
        try context.save()

        let descriptor = FetchDescriptor<MoodEntry>()
        let fetched = try context.fetch(descriptor)
        #expect(fetched.count == 1)

        let fetchedDate = fetched[0].date
        let fetchedComponents = Calendar.current.dateComponents([.year, .month, .day], from: fetchedDate)
        #expect(fetchedComponents.year == 2026)
        #expect(fetchedComponents.month == 1)
        #expect(fetchedComponents.day == 15)
    }
}

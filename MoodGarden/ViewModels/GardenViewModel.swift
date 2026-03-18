//
//  GardenViewModel.swift
//  MoodGarden
//
//  Created by Daisuke Ooba on 2026/03/17.
//

import Foundation
import SwiftData

@Observable
class GardenViewModel {
    private(set) var currentMonthEntries: [MoodEntry] = []
    private var modelContext: ModelContext

    var hasTodayEntry: Bool {
        let today = Calendar.current.startOfDay(for: Date())
        return currentMonthEntries.contains { $0.date == today }
    }

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func fetchEntries() {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: now)
        let monthStart = calendar.date(from: components)!
        let nextMonthStart = calendar.date(byAdding: .month, value: 1, to: monthStart)!

        let descriptor = FetchDescriptor<MoodEntry>(
            predicate: #Predicate { $0.date >= monthStart && $0.date < nextMonthStart },
            sortBy: [SortDescriptor(\.date)]
        )

        do {
            currentMonthEntries = try modelContext.fetch(descriptor)
        } catch {
            currentMonthEntries = []
        }
    }

    func recordMood(_ mood: MoodType) {
        guard !hasTodayEntry else { return }

        let entry = MoodEntry(mood: mood)
        modelContext.insert(entry)
        fetchEntries()
        try? modelContext.save()
    }
}

//
//  MoodEntry.swift
//  MoodGarden
//
//  Created by Daisuke Ooba on 2026/03/17.
//

import Foundation
import SwiftData

extension MoodEntry {
    static func fetch(year: Int, month: Int, from context: ModelContext) -> [MoodEntry] {
        let calendar = Calendar.current
        guard
            let monthStart = calendar.date(from: DateComponents(year: year, month: month)),
            let nextMonthStart = calendar.date(byAdding: .month, value: 1, to: monthStart)
        else { return [] }

        let descriptor = FetchDescriptor<MoodEntry>(
            predicate: #Predicate { $0.date >= monthStart && $0.date < nextMonthStart },
            sortBy: [SortDescriptor(\.date)]
        )
        return (try? context.fetch(descriptor)) ?? []
    }
}

@Model
final class MoodEntry {
    var id: UUID
    var date: Date
    var mood: MoodType
    var gardenSeed: Int
    var createdAt: Date

    init(mood: MoodType, date: Date = Date()) {
        self.id = UUID()
        self.date = Calendar.current.startOfDay(for: date)
        self.mood = mood
        self.gardenSeed = Int.random(in: 0...Int.max)
        self.createdAt = date
    }
}

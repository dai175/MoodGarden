//
//  MoodEntry.swift
//  MoodGarden
//
//  Created by Daisuke Ooba on 2026/03/17.
//

import Foundation
import SwiftData

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

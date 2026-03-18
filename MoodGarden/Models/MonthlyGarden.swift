//
//  MonthlyGarden.swift
//  MoodGarden
//
//  Created by Daisuke Ooba on 2026/03/17.
//

import Foundation
import SwiftData

@Model
final class MonthlyGarden {
    var id: UUID
    var year: Int
    var month: Int
    @Attribute(.externalStorage) var snapshotImage: Data?
    var completedAt: Date?

    init(year: Int, month: Int) {
        self.id = UUID()
        self.year = year
        self.month = month
        self.snapshotImage = nil
        self.completedAt = nil
    }
}

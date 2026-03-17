//
//  Item.swift
//  MoodGarden
//
//  Created by Daisuke Ooba on 2026/03/17.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date

    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

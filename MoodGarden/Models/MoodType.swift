//
//  MoodType.swift
//  MoodGarden
//
//  Created by Daisuke Ooba on 2026/03/17.
//

import SwiftUI
import UIKit

enum MoodType: String, Codable, CaseIterable {
    case peaceful
    case happy
    case energetic
    case anxious
    case sad
    case angry
    case tired

    var displayName: String {
        switch self {
        case .peaceful: return "Peaceful"
        case .happy: return "Happy"
        case .energetic: return "Energetic"
        case .anxious: return "Anxious"
        case .sad: return "Sad"
        case .angry: return "Angry"
        case .tired: return "Tired"
        }
    }

    var color: Color {
        Color(uiColor)
    }

    var iconName: String {
        switch self {
        case .peaceful: return "leaf.fill"
        case .happy: return "sun.max.fill"
        case .energetic: return "bolt.fill"
        case .anxious: return "cloud.fog.fill"
        case .sad: return "cloud.rain.fill"
        case .angry: return "wind"
        case .tired: return "moon.fill"
        }
    }

    var uiColor: UIColor {
        switch self {
        case .peaceful: return UIColor(red: 0.114, green: 0.620, blue: 0.459, alpha: 1)
        case .happy: return UIColor(red: 0.984, green: 0.737, blue: 0.306, alpha: 1)
        case .energetic: return UIColor(red: 0.502, green: 0.859, blue: 0.208, alpha: 1)
        case .anxious: return UIColor(red: 0.569, green: 0.545, blue: 0.620, alpha: 1)
        case .sad: return UIColor(red: 0.365, green: 0.541, blue: 0.725, alpha: 1)
        case .angry: return UIColor(red: 0.647, green: 0.165, blue: 0.165, alpha: 1)
        case .tired: return UIColor(red: 0.651, green: 0.494, blue: 0.322, alpha: 1)
        }
    }
}

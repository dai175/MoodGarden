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
        case .peaceful: return UIColor(red: 0.12, green: 0.48, blue: 0.38, alpha: 1)
        case .happy: return UIColor(red: 0.78, green: 0.62, blue: 0.32, alpha: 1)
        case .energetic: return UIColor(red: 0.38, green: 0.62, blue: 0.24, alpha: 1)
        case .anxious: return UIColor(red: 0.45, green: 0.43, blue: 0.52, alpha: 1)
        case .sad: return UIColor(red: 0.30, green: 0.44, blue: 0.58, alpha: 1)
        case .angry: return UIColor(red: 0.52, green: 0.18, blue: 0.16, alpha: 1)
        case .tired: return UIColor(red: 0.50, green: 0.40, blue: 0.28, alpha: 1)
        }
    }
}

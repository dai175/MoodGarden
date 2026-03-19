import Foundation

enum GrowthPhase: Equatable, CaseIterable {
    case seed, sprout, bloom, mature

    var scale: CGFloat {
        switch self {
        case .seed: return 0.3
        case .sprout: return 0.6
        case .bloom: return 1.0
        case .mature: return 1.0
        }
    }

    var alpha: CGFloat {
        switch self {
        case .seed: return 0.4
        case .sprout: return 0.7
        case .bloom: return 1.0
        case .mature: return 0.9
        }
    }

    static func from(daysSinceCreation: Int) -> GrowthPhase {
        switch daysSinceCreation {
        case 0: return .seed
        case 1: return .sprout
        case 2: return .bloom
        default: return .mature
        }
    }
}

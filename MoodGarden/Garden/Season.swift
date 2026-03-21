import UIKit

enum Season: CaseIterable {
    case spring, summer, autumn, winter

    static func from(month: Int) -> Season {
        switch month {
        case 3, 4, 5:
            return .spring
        case 6, 7, 8:
            return .summer
        case 9, 10, 11:
            return .autumn
        default:
            return .winter
        }
    }

    var backgroundImageName: String {
        switch self {
        case .spring: return "bg_spring"
        case .summer: return "bg_summer"
        case .autumn: return "bg_autumn"
        case .winter: return "bg_winter"
        }
    }

    struct GradientColors {
        let top: UIColor
        let bottom: UIColor
    }

    var gradientColors: GradientColors {
        switch self {
        case .spring:
            return GradientColors(
                top: UIColor(red: 0.06, green: 0.12, blue: 0.10, alpha: 1.0),
                bottom: UIColor(red: 0.04, green: 0.08, blue: 0.05, alpha: 1.0)
            )
        case .summer:
            return GradientColors(
                top: UIColor(red: 0.06, green: 0.10, blue: 0.08, alpha: 1.0),
                bottom: UIColor(red: 0.04, green: 0.09, blue: 0.05, alpha: 1.0)
            )
        case .autumn:
            return GradientColors(
                top: UIColor(red: 0.07, green: 0.10, blue: 0.09, alpha: 1.0),
                bottom: UIColor(red: 0.04, green: 0.08, blue: 0.05, alpha: 1.0)
            )
        case .winter:
            return GradientColors(
                top: UIColor(red: 0.05, green: 0.08, blue: 0.12, alpha: 1.0),
                bottom: UIColor(red: 0.03, green: 0.06, blue: 0.08, alpha: 1.0)
            )
        }
    }

    var tintColor: UIColor {
        switch self {
        case .spring:
            return UIColor(red: 0.2, green: 0.8, blue: 0.3, alpha: 0.03)
        case .summer:
            return UIColor(red: 0.8, green: 0.6, blue: 0.2, alpha: 0.04)
        case .autumn:
            return UIColor(red: 0.8, green: 0.4, blue: 0.1, alpha: 0.04)
        case .winter:
            return UIColor(red: 0.3, green: 0.4, blue: 0.7, alpha: 0.04)
        }
    }
}

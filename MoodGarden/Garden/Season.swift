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

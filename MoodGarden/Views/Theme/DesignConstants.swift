import SwiftUI
import UIKit

enum DesignConstants {

    enum Colors {
        static let backgroundPrimary = Color(red: 0.039, green: 0.102, blue: 0.071)  // #0A1A12
        static let backgroundSecondary = Color(red: 0.051, green: 0.157, blue: 0.094)  // #0D2818
        static let textPrimary = Color(red: 0.910, green: 0.894, blue: 0.863)  // #E8E4DC
        static let textOpacity: Double = 0.8
        static let textSubdued = textPrimary.opacity(textOpacity)
        static let accent = Color(red: 0.114, green: 0.620, blue: 0.459)  // #1D9E75

        static let backgroundPrimaryUIColor = UIColor(red: 0.039, green: 0.102, blue: 0.071, alpha: 1)
    }

    enum Animation {
        static let standard: SwiftUI.Animation = .easeInOut(duration: 0.8)
        static let slow: SwiftUI.Animation = .easeInOut(duration: 1.2)
        static let subtle: SwiftUI.Animation = .easeInOut(duration: 1.5)
    }

    enum Typography {
        static let monthTitle: Font = .title3.weight(.thin)
        static let bodyText: Font = .body.weight(.light)
        static let caption: Font = .caption.weight(.thin)
    }

    enum Formatters {
        static let monthYear: DateFormatter = {
            let formatter = DateFormatter()
            formatter.setLocalizedDateFormatFromTemplate("MMMM yyyy")
            return formatter
        }()
    }

    enum Layout {
        static let gridColumns = 7
        static let gridRows = 5
        static let cellSpacing: CGFloat = 8
        static let cornerRadius: CGFloat = 12
        static let glassOpacity: Double = 0.15
    }
}

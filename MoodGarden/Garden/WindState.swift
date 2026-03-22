import CoreGraphics
import Foundation

struct WindState {
    static let minStrength: CGFloat = 0.05
    static let maxStrength: CGFloat = 0.3

    private(set) var direction: CGFloat = 0.0
    private(set) var strength: CGFloat = minStrength

    private let strengthPeriod: TimeInterval = 10.0
    private let directionPeriod: TimeInterval = 25.0
    private var firstTime: TimeInterval = 0
    private var initialized = false

    mutating func update(currentTime: TimeInterval) {
        if !initialized {
            firstTime = currentTime
            initialized = true
            return
        }

        let elapsed = currentTime - firstTime

        let strengthPhase = elapsed / strengthPeriod * 2.0 * .pi
        let normalizedStrength = (sin(strengthPhase) + 1.0) / 2.0
        strength =
            Self.minStrength
            + (Self.maxStrength - Self.minStrength) * CGFloat(normalizedStrength)

        let directionPhase = elapsed / directionPeriod * 2.0 * .pi
        direction = CGFloat(sin(directionPhase)) * 0.5
    }
}

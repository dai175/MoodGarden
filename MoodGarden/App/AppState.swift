import SwiftUI

@Observable
class AppState {
    private enum Keys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let lastActiveYear = "lastActiveYear"
        static let lastActiveMonth = "lastActiveMonth"
    }

    @ObservationIgnored
    @AppStorage(Keys.hasCompletedOnboarding) private var _hasCompletedOnboarding: Bool = false

    @ObservationIgnored
    @AppStorage(Keys.lastActiveYear) private var _lastActiveYear: Int = 0

    @ObservationIgnored
    @AppStorage(Keys.lastActiveMonth) private var _lastActiveMonth: Int = 0

    var hasCompletedOnboarding: Bool {
        get { _hasCompletedOnboarding }
        set { _hasCompletedOnboarding = newValue }
    }

    var lastActiveYear: Int {
        get { _lastActiveYear }
        set { _lastActiveYear = newValue }
    }

    var lastActiveMonth: Int {
        get { _lastActiveMonth }
        set { _lastActiveMonth = newValue }
    }
}

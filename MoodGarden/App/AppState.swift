import SwiftUI

@Observable
class AppState {
    @ObservationIgnored
    @AppStorage("hasCompletedOnboarding") private var _hasCompletedOnboarding: Bool = false

    @ObservationIgnored
    @AppStorage("lastActiveYear") private var _lastActiveYear: Int = 0

    @ObservationIgnored
    @AppStorage("lastActiveMonth") private var _lastActiveMonth: Int = 0

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

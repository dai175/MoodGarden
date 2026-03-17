import SwiftUI

@Observable
class AppState {
    @ObservationIgnored
    @AppStorage("hasCompletedOnboarding") private var _hasCompletedOnboarding: Bool = false

    var hasCompletedOnboarding: Bool {
        get { _hasCompletedOnboarding }
        set { _hasCompletedOnboarding = newValue }
    }
}

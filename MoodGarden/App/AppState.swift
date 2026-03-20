import SwiftUI

@Observable
class AppState {
    private enum Keys {
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let lastActiveYear = "lastActiveYear"
        static let lastActiveMonth = "lastActiveMonth"
        static let totalRecordCount = "totalRecordCount"
    }

    @ObservationIgnored
    @AppStorage(Keys.hasCompletedOnboarding) private var _hasCompletedOnboarding: Bool = false

    @ObservationIgnored
    @AppStorage(Keys.lastActiveYear) private var _lastActiveYear: Int = 0

    @ObservationIgnored
    @AppStorage(Keys.lastActiveMonth) private var _lastActiveMonth: Int = 0

    @ObservationIgnored
    @AppStorage(Keys.totalRecordCount) private var _totalRecordCount: Int = 0

    var hasCompletedOnboarding: Bool {
        get {
            access(keyPath: \.hasCompletedOnboarding)
            return _hasCompletedOnboarding
        }
        set {
            withMutation(keyPath: \.hasCompletedOnboarding) {
                _hasCompletedOnboarding = newValue
            }
        }
    }

    var lastActiveYear: Int {
        get {
            access(keyPath: \.lastActiveYear)
            return _lastActiveYear
        }
        set {
            withMutation(keyPath: \.lastActiveYear) {
                _lastActiveYear = newValue
            }
        }
    }

    var lastActiveMonth: Int {
        get {
            access(keyPath: \.lastActiveMonth)
            return _lastActiveMonth
        }
        set {
            withMutation(keyPath: \.lastActiveMonth) {
                _lastActiveMonth = newValue
            }
        }
    }

    var totalRecordCount: Int {
        get {
            access(keyPath: \.totalRecordCount)
            return _totalRecordCount
        }
        set {
            withMutation(keyPath: \.totalRecordCount) {
                _totalRecordCount = newValue
            }
        }
    }
}

import UserNotifications

@Observable
final class NotificationService {
    enum Frequency: Int, Comparable {
        case daily = 1
        case everyOtherDay = 2
        case twiceAWeek = 3

        static func < (lhs: Frequency, rhs: Frequency) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    private enum Keys {
        static let enabled = "notificationEnabled"
        static let hour = "notificationHour"
        static let minute = "notificationMinute"
        static let lastActiveDate = "lastActiveDate"
        static let frequency = "notificationFrequency"
    }

    private static let messages = [
        "What's the weather in your garden today?",
        "How does today feel?",
        "Your garden is waiting quietly.",
        "One tap. That's all it takes.",
    ]

    @ObservationIgnored
    private let defaults: UserDefaults

    var isEnabled: Bool {
        get { defaults.bool(forKey: Keys.enabled) }
        set {
            defaults.set(newValue, forKey: Keys.enabled)
            Task { await scheduleNotifications() }
        }
    }

    var scheduledHour: Int {
        get {
            let val = defaults.integer(forKey: Keys.hour)
            return val == 0 && !defaults.contains(key: Keys.hour) ? 21 : val
        }
        set { defaults.set(newValue, forKey: Keys.hour) }
    }

    var scheduledMinute: Int {
        get { defaults.integer(forKey: Keys.minute) }
        set { defaults.set(newValue, forKey: Keys.minute) }
    }

    private var lastActiveDate: Date? {
        get { defaults.object(forKey: Keys.lastActiveDate) as? Date }
        set { defaults.set(newValue, forKey: Keys.lastActiveDate) }
    }

    private var currentFrequency: Frequency {
        get { Frequency(rawValue: defaults.integer(forKey: Keys.frequency)) ?? .daily }
        set { defaults.set(newValue.rawValue, forKey: Keys.frequency) }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if !defaults.contains(key: Keys.enabled) {
            defaults.set(true, forKey: Keys.enabled)
        }
    }

    func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound])
        } catch {
            return false
        }
    }

    func scheduleNotifications() async {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        guard isEnabled else { return }

        let settings = await center.notificationSettings()
        guard settings.authorizationStatus == .authorized else { return }

        let daysToSchedule = scheduleDays(for: currentFrequency)

        for (index, weekday) in daysToSchedule.enumerated() {
            var dateComponents = DateComponents()
            dateComponents.hour = scheduledHour
            dateComponents.minute = scheduledMinute
            dateComponents.weekday = weekday

            let content = UNMutableNotificationContent()
            content.title = "Mood Garden"
            content.body = Self.message(forIndex: index)
            content.sound = .default

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: dateComponents, repeats: true
            )
            let request = UNNotificationRequest(
                identifier: "moodgarden-\(weekday)",
                content: content,
                trigger: trigger
            )
            try? await center.add(request)
        }
    }

    func updateTime(hour: Int, minute: Int) async {
        scheduledHour = hour
        scheduledMinute = minute
        await scheduleNotifications()
    }

    func recordActivity() {
        lastActiveDate = Date()
        let newFrequency = Self.calculateFrequency(
            daysSinceLastUse: 0,
            current: currentFrequency
        )
        if newFrequency != currentFrequency {
            currentFrequency = newFrequency
            Task { await scheduleNotifications() }
        }
    }

    func updateFrequencyIfNeeded() {
        guard let lastActive = lastActiveDate else { return }
        let days =
            Calendar.current.dateComponents(
                [.day], from: lastActive, to: Date()
            ).day ?? 0
        let newFrequency = Self.calculateFrequency(
            daysSinceLastUse: days,
            current: currentFrequency
        )
        if newFrequency != currentFrequency {
            currentFrequency = newFrequency
            Task { await scheduleNotifications() }
        }
    }

    static func calculateFrequency(
        daysSinceLastUse: Int,
        current: Frequency
    ) -> Frequency {
        let calculated: Frequency
        if daysSinceLastUse >= 7 {
            calculated = .twiceAWeek
        } else if daysSinceLastUse >= 3 {
            calculated = .everyOtherDay
        } else {
            calculated = .daily
        }
        return max(current, calculated)
    }

    static func message(forIndex index: Int) -> String {
        messages[index % messages.count]
    }

    private func scheduleDays(for frequency: Frequency) -> [Int] {
        switch frequency {
        case .daily:
            return [1, 2, 3, 4, 5, 6, 7]
        case .everyOtherDay:
            return [1, 3, 5, 7]
        case .twiceAWeek:
            return [1, 4]
        }
    }
}

extension UserDefaults {
    func contains(key: String) -> Bool {
        object(forKey: key) != nil
    }
}

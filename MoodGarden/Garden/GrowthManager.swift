import Foundation

enum GrowthManager {
    static func phase(createdAt: Date, referenceDate: Date = Date()) -> GrowthPhase {
        let calendar = Calendar.current
        let days =
            calendar.dateComponents(
                [.day],
                from: calendar.startOfDay(for: createdAt),
                to: calendar.startOfDay(for: referenceDate)
            ).day ?? 0
        return GrowthPhase.from(daysSinceCreation: max(0, days))
    }
}

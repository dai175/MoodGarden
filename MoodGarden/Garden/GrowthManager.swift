import Foundation

enum GrowthManager {
    static func phase(createdAt: Date, referenceDate: Date = Date()) -> GrowthPhase {
        let calendar = Calendar.current
        let refStart = calendar.startOfDay(for: referenceDate)
        let days =
            calendar.dateComponents(
                [.day],
                from: calendar.startOfDay(for: createdAt),
                to: refStart
            ).day ?? 0
        return GrowthPhase.from(daysSinceCreation: max(0, days))
    }

    /// Batch-optimized: reuses pre-computed referenceDate startOfDay.
    static func phase(createdAt: Date, referenceStartOfDay: Date) -> GrowthPhase {
        let days =
            Calendar.current.dateComponents(
                [.day],
                from: Calendar.current.startOfDay(for: createdAt),
                to: referenceStartOfDay
            ).day ?? 0
        return GrowthPhase.from(daysSinceCreation: max(0, days))
    }
}

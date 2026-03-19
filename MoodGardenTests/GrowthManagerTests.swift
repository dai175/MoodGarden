import Foundation
import Testing

@testable import MoodGarden

struct GrowthManagerTests {
    @Test func todayEntryIsSeed() {
        let today = Date()
        let phase = GrowthManager.phase(createdAt: today, referenceDate: today)
        #expect(phase == .seed)
    }

    @Test func yesterdayEntryIsSprout() {
        let today = Date()
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let phase = GrowthManager.phase(createdAt: yesterday, referenceDate: today)
        #expect(phase == .sprout)
    }

    @Test func twoDaysAgoIsBloom() {
        let today = Date()
        let twoDaysAgo = Calendar.current.date(byAdding: .day, value: -2, to: today)!
        let phase = GrowthManager.phase(createdAt: twoDaysAgo, referenceDate: today)
        #expect(phase == .bloom)
    }

    @Test func threeDaysAgoIsMature() {
        let today = Date()
        let threeDaysAgo = Calendar.current.date(byAdding: .day, value: -3, to: today)!
        let phase = GrowthManager.phase(createdAt: threeDaysAgo, referenceDate: today)
        #expect(phase == .mature)
    }

    @Test func thirtyDaysAgoIsMature() {
        let today = Date()
        let old = Calendar.current.date(byAdding: .day, value: -30, to: today)!
        let phase = GrowthManager.phase(createdAt: old, referenceDate: today)
        #expect(phase == .mature)
    }
}

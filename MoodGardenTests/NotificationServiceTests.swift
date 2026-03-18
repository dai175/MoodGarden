import Testing

@testable import MoodGarden

@Suite("NotificationService Tests")
struct NotificationServiceTests {
    @Test("Default frequency is daily")
    func defaultFrequency() {
        let result = NotificationService.calculateFrequency(
            daysSinceLastUse: 0,
            current: .daily
        )
        #expect(result == .daily)
    }

    @Test("3+ days inactive reduces to every other day")
    func threeInactiveDays() {
        let result = NotificationService.calculateFrequency(
            daysSinceLastUse: 3,
            current: .daily
        )
        #expect(result == .everyOtherDay)
    }

    @Test("7+ days inactive reduces to twice a week")
    func sevenInactiveDays() {
        let result = NotificationService.calculateFrequency(
            daysSinceLastUse: 7,
            current: .daily
        )
        #expect(result == .twiceAWeek)
    }

    @Test("Frequency never increases — twiceAWeek stays even at 0 days")
    func frequencyNeverIncreases() {
        let result = NotificationService.calculateFrequency(
            daysSinceLastUse: 0,
            current: .twiceAWeek
        )
        #expect(result == .twiceAWeek)
    }

    @Test("everyOtherDay does not go back to daily")
    func everyOtherDayStays() {
        let result = NotificationService.calculateFrequency(
            daysSinceLastUse: 1,
            current: .everyOtherDay
        )
        #expect(result == .everyOtherDay)
    }

    @Test("Message rotation cycles through 4 messages")
    func messageRotation() {
        let messages = (0..<4).map { NotificationService.message(forIndex: $0) }
        #expect(messages.count == 4)
        #expect(Set(messages).count == 4)
    }

    @Test("Message index wraps around")
    func messageWraps() {
        let first = NotificationService.message(forIndex: 0)
        let fifth = NotificationService.message(forIndex: 4)
        #expect(first == fifth)
    }
}

import Foundation
import Testing

@testable import MoodGarden

struct WindStateTests {
    @Test func initialState() {
        let wind = WindState()
        #expect(wind.strength == WindState.minStrength)
        #expect(wind.direction == 0.0)
    }

    @Test func updateChangesStrength() {
        var wind = WindState()
        wind.update(currentTime: 0)
        let initial = wind.strength
        wind.update(currentTime: 5.0)
        #expect(wind.strength != initial)
    }

    @Test func strengthStaysInRange() {
        var wind = WindState()
        for i in 0..<600 {
            wind.update(currentTime: TimeInterval(i) * 0.1)
            #expect(wind.strength >= WindState.minStrength)
            #expect(wind.strength <= WindState.maxStrength)
        }
    }

    @Test func directionChangesOverTime() {
        var wind = WindState()
        wind.update(currentTime: 0)
        let initialDirection = wind.direction
        wind.update(currentTime: 12.5)
        #expect(wind.direction != initialDirection)
    }
}

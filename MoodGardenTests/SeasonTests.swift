import SpriteKit
import Testing

@testable import MoodGarden

@Suite("Season Tests")
struct SeasonTests {

    // MARK: - Season.from(month:) tests

    @Test("Spring months: March, April, May")
    func springMonths() {
        #expect(Season.from(month: 3) == .spring)
        #expect(Season.from(month: 4) == .spring)
        #expect(Season.from(month: 5) == .spring)
    }

    @Test("Summer months: June, July, August")
    func summerMonths() {
        #expect(Season.from(month: 6) == .summer)
        #expect(Season.from(month: 7) == .summer)
        #expect(Season.from(month: 8) == .summer)
    }

    @Test("Autumn months: September, October, November")
    func autumnMonths() {
        #expect(Season.from(month: 9) == .autumn)
        #expect(Season.from(month: 10) == .autumn)
        #expect(Season.from(month: 11) == .autumn)
    }

    @Test("Winter months: December, January, February")
    func winterMonths() {
        #expect(Season.from(month: 12) == .winter)
        #expect(Season.from(month: 1) == .winter)
        #expect(Season.from(month: 2) == .winter)
    }

    @Test("All 12 months return a valid season")
    func allTwelveMonths() {
        let validSeasons: Set<Season> = [.spring, .summer, .autumn, .winter]
        for month in 1...12 {
            let season = Season.from(month: month)
            #expect(validSeasons.contains(season), "Month \(month) should return a valid season")
        }
    }

    @Test("Season has 4 cases")
    func fourCases() {
        #expect(Season.allCases.count == 4)
    }

    @Test("Boundary: spring starts at month 3, ends at month 5")
    func springBoundary() {
        #expect(Season.from(month: 2) != .spring)
        #expect(Season.from(month: 3) == .spring)
        #expect(Season.from(month: 5) == .spring)
        #expect(Season.from(month: 6) != .spring)
    }

    @Test("Boundary: winter wraps across year boundary")
    func winterBoundary() {
        #expect(Season.from(month: 11) != .winter)
        #expect(Season.from(month: 12) == .winter)
        #expect(Season.from(month: 1) == .winter)
        #expect(Season.from(month: 2) == .winter)
        #expect(Season.from(month: 3) != .winter)
    }
}

@Suite("SeasonalLayer Tests")
@MainActor
struct SeasonalLayerTests {
    private let sceneSize = CGSize(width: 350, height: 250)

    @Test("Spring configuration adds child nodes")
    func springAddsChildren() {
        let layer = SeasonalLayer()
        layer.configure(season: .spring, sceneSize: sceneSize)
        #expect(!layer.children.isEmpty)
    }

    @Test("Summer configuration adds child nodes")
    func summerAddsChildren() {
        let layer = SeasonalLayer()
        layer.configure(season: .summer, sceneSize: sceneSize)
        #expect(!layer.children.isEmpty)
    }

    @Test("Autumn configuration adds child nodes")
    func autumnAddsChildren() {
        let layer = SeasonalLayer()
        layer.configure(season: .autumn, sceneSize: sceneSize)
        #expect(!layer.children.isEmpty)
    }

    @Test("Winter configuration adds child nodes")
    func winterAddsChildren() {
        let layer = SeasonalLayer()
        layer.configure(season: .winter, sceneSize: sceneSize)
        #expect(!layer.children.isEmpty)
    }

    @Test("Each season produces an overlay and an emitter node")
    func eachSeasonHasOverlayAndEmitter() {
        for season in Season.allCases {
            let layer = SeasonalLayer()
            layer.configure(season: season, sceneSize: sceneSize)
            let hasShape = layer.children.contains { $0 is SKShapeNode }
            let hasEmitter = layer.children.contains { $0 is SKEmitterNode }
            #expect(hasShape, "\(season) should have an SKShapeNode overlay")
            #expect(hasEmitter, "\(season) should have an SKEmitterNode particle")
        }
    }

    @Test("Reconfiguring replaces previous children")
    func reconfigureReplacesChildren() {
        let layer = SeasonalLayer()
        layer.configure(season: .spring, sceneSize: sceneSize)
        let firstCount = layer.children.count

        layer.configure(season: .winter, sceneSize: sceneSize)
        let secondCount = layer.children.count

        #expect(firstCount == secondCount)
    }
}

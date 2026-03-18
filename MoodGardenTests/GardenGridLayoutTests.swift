import CoreGraphics
import Testing

@testable import MoodGarden

@Suite("GardenGridLayout Tests")
struct GardenGridLayoutTests {
    let layout = GardenGridLayout(
        columns: 7,
        rows: 5,
        sceneSize: CGSize(width: 350, height: 250),
        spacing: 8
    )

    @Test("Day 1 is top-left, day 7 is top-right")
    func topRow() {
        let pos1 = layout.position(forDay: 1)
        let pos7 = layout.position(forDay: 7)

        #expect(pos1.x < pos7.x)
        #expect(abs(pos1.y - pos7.y) < 0.001)
    }

    @Test("Day 8 is below day 1")
    func secondRow() {
        let pos1 = layout.position(forDay: 1)
        let pos8 = layout.position(forDay: 8)

        #expect(abs(pos1.x - pos8.x) < 0.001)
        #expect(pos1.y > pos8.y)
    }

    @Test("Day 35 is bottom-right")
    func bottomRight() {
        let pos1 = layout.position(forDay: 1)
        let pos35 = layout.position(forDay: 35)

        #expect(pos35.x > pos1.x)
        #expect(pos35.y < pos1.y)
    }

    @Test("Cell size scales with scene size")
    func cellSizeScaling() {
        let smallLayout = GardenGridLayout(
            columns: 7, rows: 5,
            sceneSize: CGSize(width: 175, height: 125),
            spacing: 8
        )
        #expect(smallLayout.cellSize.width < layout.cellSize.width)
        #expect(smallLayout.cellSize.height < layout.cellSize.height)
    }

    @Test("Spacing is applied between cells")
    func spacingApplied() {
        let pos1 = layout.position(forDay: 1)
        let pos2 = layout.position(forDay: 2)
        let expectedGap = layout.cellSize.width + layout.spacing
        let actualGap = pos2.x - pos1.x

        #expect(abs(actualGap - expectedGap) < 0.001)
    }

    @Test("Grid is centered around origin")
    func gridCentered() {
        let pos1 = layout.position(forDay: 1)
        let pos35 = layout.position(forDay: 35)

        #expect(abs(pos1.x + pos35.x) < 0.001)
        #expect(abs(pos1.y + pos35.y) < 0.001)
    }
}

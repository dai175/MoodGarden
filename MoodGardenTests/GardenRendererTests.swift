import CoreGraphics
import SpriteKit
import Testing

@testable import MoodGarden

@Suite("GardenRenderer Tests")
struct GardenRendererTests {
    let renderer = GardenRenderer()
    let cellSize = CGSize(width: 40, height: 40)

    @Test("Creates node for each mood type", arguments: MoodType.allCases)
    func createsNodeForMood(mood: MoodType) {
        let data = GardenElementData(day: 1, mood: mood, seed: 42)
        let node = renderer.createNode(for: data, cellSize: cellSize)
        #expect(node.children.isEmpty == false)
    }

    @Test("Node name follows element_day_N format")
    func nodeNaming() {
        let data = GardenElementData(day: 15, mood: .happy, seed: 42)
        let node = renderer.createNode(for: data, cellSize: cellSize)
        #expect(node.name == "element_day_15")
    }

    @Test("Same seed produces same child count")
    func deterministicWithSameSeed() {
        let data = GardenElementData(day: 1, mood: .peaceful, seed: 123)
        let node1 = renderer.createNode(for: data, cellSize: cellSize)
        let node2 = renderer.createNode(for: data, cellSize: cellSize)
        #expect(node1.children.count == node2.children.count)
    }

    @Test("Different seeds can produce different variations")
    func differentSeeds() {
        var childCounts: Set<Int> = []
        for seed in 0..<20 {
            let data = GardenElementData(day: 1, mood: .peaceful, seed: seed)
            let node = renderer.createNode(for: data, cellSize: cellSize)
            childCounts.insert(node.children.count)
        }
        #expect(childCounts.count > 1)
    }

    @Test("createNodes returns correct count and positions")
    func createNodesWithLayout() {
        let layout = GardenGridLayout(
            columns: 7, rows: 5,
            sceneSize: CGSize(width: 350, height: 250),
            spacing: 8
        )
        let entries = [
            GardenElementData(day: 1, mood: .happy, seed: 1),
            GardenElementData(day: 2, mood: .sad, seed: 2),
        ]
        let results = renderer.createNodes(for: entries, layout: layout)
        #expect(results.count == 2)
        #expect(results[0].position.x < results[1].position.x)
    }
}

import CoreGraphics
import Foundation
import SpriteKit
import Testing

@testable import MoodGarden

@Suite("GardenRenderer Tests")
struct GardenRendererTests {
    let renderer = GardenRenderer()
    let sceneSize = CGSize(width: 350, height: 250)

    private func makeSpec(
        elementType: ElementType = .flower,
        seed: Int = 42,
        phase: GrowthPhase = .bloom
    ) -> ElementSpec {
        ElementSpec(
            entryID: UUID(),
            elementType: elementType,
            seed: seed,
            phase: phase,
            zone: .hilltop,
            estimatedNodes: 3
        )
    }

    @Test(
        "Creates node for each implemented element type",
        arguments: [
            ElementType.moss, .flower, .grass, .fog, .raindrop, .wind, .fallenLeaf,
            .butterfly, .sunray, .rainbow, .puddle, .ripple, .vine, .mushroom,
        ]
    )
    func createsNodeForElementType(elementType: ElementType) {
        let spec = makeSpec(elementType: elementType)
        let node = renderer.createNode(for: spec, sceneSize: sceneSize)
        #expect(node.children.isEmpty == false)
    }

    @Test("Node name contains element type")
    func nodeNaming() {
        let spec = makeSpec(elementType: .flower, seed: 42)
        let node = renderer.createNode(for: spec, sceneSize: sceneSize)
        #expect(node.name?.contains("flower") == true)
    }

    @Test("Same seed produces same child count")
    func deterministicWithSameSeed() {
        let spec = makeSpec(elementType: .moss, seed: 123)
        let node1 = renderer.createNode(for: spec, sceneSize: sceneSize)
        let node2 = renderer.createNode(for: spec, sceneSize: sceneSize)
        #expect(node1.children.count == node2.children.count)
    }

    @Test("Different seeds can produce different variations")
    func differentSeeds() {
        var childCounts: Set<Int> = []
        for seed in 0..<20 {
            let spec = makeSpec(elementType: .moss, seed: seed)
            let node = renderer.createNode(for: spec, sceneSize: sceneSize)
            childCounts.insert(node.children.count)
        }
        #expect(childCounts.count > 1)
    }

    @Test("createNodes returns correct count matching positions")
    func createNodesWithPositions() {
        let specs = [
            makeSpec(elementType: .flower, seed: 1),
            makeSpec(elementType: .moss, seed: 2),
        ]
        let positions = [
            CGPoint(x: -50, y: 30),
            CGPoint(x: 50, y: -30),
        ]
        let results = renderer.createNodes(for: specs, positions: positions, sceneSize: sceneSize)
        #expect(results.count == 2)
        #expect(results[0].position.x < results[1].position.x)
    }

    @Test("Registered element type creates named node")
    func registeredElementType() {
        let spec = makeSpec(elementType: .butterfly)
        let node = renderer.createNode(for: spec, sceneSize: sceneSize)
        #expect(node.name?.contains("butterfly") == true)
    }

    @Test("Growth phase affects node scale")
    func growthPhaseApplied() {
        let seedSpec = makeSpec(phase: .seed)
        let bloomSpec = makeSpec(phase: .bloom)
        let seedNode = renderer.createNode(for: seedSpec, sceneSize: sceneSize)
        let bloomNode = renderer.createNode(for: bloomSpec, sceneSize: sceneSize)
        #expect(seedNode.xScale < bloomNode.xScale)
    }
}

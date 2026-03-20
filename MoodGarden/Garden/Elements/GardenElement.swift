import GameplayKit
import SpriteKit

protocol GardenElement {
    var elementType: ElementType { get }
    var preferredZone: PlacementZone { get }
    var estimatedNodes: Int { get }

    func createNode(seed: Int, phase: GrowthPhase, sceneSize: CGSize) -> SKNode
}

extension GardenElement {
    func makeRandom(seed: Int) -> GKMersenneTwisterRandomSource {
        GKMersenneTwisterRandomSource(seed: UInt64(bitPattern: Int64(seed)))
    }

    func nextFloat(_ random: GKMersenneTwisterRandomSource, min: Float, max: Float) -> CGFloat {
        CGFloat(random.nextUniform() * (max - min) + min)
    }

    /// Reference size derived from scene size (replaces former cellSize).
    func refSize(from sceneSize: CGSize) -> CGSize {
        CGSize(width: sceneSize.width / 8, height: sceneSize.height / 6)
    }

    /// Apply growth phase scale and alpha to a node.
    func applyGrowthPhase(_ phase: GrowthPhase, to node: SKNode) {
        node.setScale(phase.scale)
        node.alpha *= phase.alpha
    }

    /// Scale animation durations by growth phase (mature elements animate slower).
    func animationSpeed(for phase: GrowthPhase) -> CGFloat {
        switch phase {
        case .seed: return 1.3
        case .sprout: return 1.1
        case .bloom: return 1.0
        case .mature: return 0.9
        }
    }
}

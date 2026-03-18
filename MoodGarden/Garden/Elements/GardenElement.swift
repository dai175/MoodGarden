import GameplayKit
import SpriteKit

protocol GardenElement {
    func createNode(seed: Int, cellSize: CGSize) -> SKNode
}

extension GardenElement {
    func makeRandom(seed: Int) -> GKMersenneTwisterRandomSource {
        GKMersenneTwisterRandomSource(seed: UInt64(bitPattern: Int64(seed)))
    }

    func nextFloat(_ random: GKMersenneTwisterRandomSource, min: Float, max: Float) -> CGFloat {
        CGFloat(random.nextUniform() * (max - min) + min)
    }
}

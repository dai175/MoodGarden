import GameplayKit
import SpriteKit

struct FogElement: GardenElement {
    let elementType = ElementType.fog
    let preferredZone = PlacementZone.anywhere
    let estimatedNodes = 1

    func createNode(seed: Int, phase: GrowthPhase, sceneSize: CGSize) -> SKNode {
        let random = makeRandom(seed: seed)

        let widthFrac = nextFloat(random, min: 0.8, max: 1.2)
        let sprite = makeImageSprite(named: "elem_fog", sceneSize: sceneSize, widthFraction: widthFrac)
        sprite.alpha = nextFloat(random, min: 0.25, max: 0.45)
        applyGrowthPhase(phase, to: sprite)

        return sprite
    }
}

import GameplayKit
import SpriteKit

struct RippleElement: GardenElement {
    let elementType = ElementType.ripple
    let preferredZone = PlacementZone.waterside
    let estimatedNodes = 3

    func createNode(seed: Int, phase: GrowthPhase, sceneSize: CGSize) -> SKNode {
        let random = makeRandom(seed: seed)
        let cellSize = refSize(from: sceneSize)
        let speed = animationSpeed(for: phase)
        let container = SKNode()

        let ringCount = 2 + Int(random.nextInt(upperBound: 2))
        let maxRadius = nextFloat(random, min: 0.2, max: 0.35) * cellSize.width

        for index in 0..<ringCount {
            let startRadius = nextFloat(random, min: 0.03, max: 0.06) * cellSize.width
            let ring = SKShapeNode(circleOfRadius: startRadius)
            ring.strokeColor = MoodType.sad.uiColor
            ring.fillColor = .clear
            ring.lineWidth = nextFloat(random, min: 0.8, max: 1.5)
            ring.alpha = nextFloat(random, min: 0.5, max: 0.7)

            // Scale up and fade out, then reset
            let expandDuration = nextFloat(random, min: 2.0, max: 3.0) * speed
            let targetScale = maxRadius / startRadius
            let expand = SKAction.scale(to: targetScale, duration: expandDuration)
            expand.timingMode = .easeOut
            let fadeOut = SKAction.fadeOut(withDuration: expandDuration)
            fadeOut.timingMode = .easeIn
            let reset = SKAction.group([
                SKAction.scale(to: 1.0, duration: 0),
                SKAction.fadeAlpha(to: ring.alpha, duration: 0),
            ])

            let phaseDelay = SKAction.wait(
                forDuration: Double(index) * expandDuration / CGFloat(ringCount))
            ring.run(
                .sequence([
                    phaseDelay,
                    .repeatForever(
                        .sequence([
                            .group([expand, fadeOut]),
                            reset,
                        ])),
                ]))

            container.addChild(ring)
        }

        applyGrowthPhase(phase, to: container)
        return container
    }
}

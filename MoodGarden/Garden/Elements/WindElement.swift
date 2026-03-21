import GameplayKit
import SpriteKit

struct WindElement: GardenElement {
    let elementType = ElementType.wind
    let preferredZone = PlacementZone.sky
    let estimatedNodes = 4

    func createNode(seed: Int, phase: GrowthPhase, sceneSize: CGSize) -> SKNode {
        let random = makeRandom(seed: seed)
        let cellSize = refSize(from: sceneSize)
        let speed = animationSpeed(for: phase)
        let container = SKNode()
        let lineCount = 2 + Int(random.nextInt(upperBound: 3))

        for _ in 0..<lineCount {
            let length = nextFloat(random, min: 0.3, max: 0.6) * cellSize.width
            let angle = nextFloat(random, min: -0.3, max: 0.3)
            let thickness = nextFloat(random, min: 1.5, max: 3.0)

            let wisp = makeSoftEllipse(
                size: CGSize(width: length, height: thickness * 2),
                color: MoodType.angry.uiColor,
                softness: 0.5
            )
            wisp.alpha = nextFloat(random, min: 0.25, max: 0.5)
            wisp.zRotation = angle
            wisp.position = CGPoint(
                x: nextFloat(random, min: -0.15, max: 0.15) * cellSize.width,
                y: nextFloat(random, min: -0.2, max: 0.2) * cellSize.height
            )

            let drift = nextFloat(random, min: 0.15, max: 0.3) * cellSize.width
            let move = SKAction.sequence([
                SKAction.moveBy(
                    x: drift, y: drift * 0.3,
                    duration: nextFloat(random, min: 0.8, max: 1.2) * speed),
                SKAction.moveBy(
                    x: -drift, y: -drift * 0.3,
                    duration: nextFloat(random, min: 0.8, max: 1.2) * speed),
            ])
            wisp.run(.repeatForever(move))

            let baseAlpha = wisp.alpha
            let alphaStrong = min(baseAlpha * 1.3, 0.6)
            let alphaWeak = baseAlpha * 0.4
            let fadeStrong = SKAction.fadeAlpha(
                to: alphaStrong,
                duration: nextFloat(random, min: 0.8, max: 1.1) * speed)
            fadeStrong.timingMode = .easeInEaseOut
            let fadeWeak = SKAction.fadeAlpha(
                to: alphaWeak,
                duration: nextFloat(random, min: 0.8, max: 1.3) * speed)
            fadeWeak.timingMode = .easeInEaseOut
            let fadeBase = SKAction.fadeAlpha(
                to: baseAlpha,
                duration: nextFloat(random, min: 0.8, max: 1.1) * speed)
            fadeBase.timingMode = .easeInEaseOut
            let gust = SKAction.sequence([fadeStrong, fadeWeak, fadeBase])
            wisp.run(.repeatForever(gust))

            container.addChild(wisp)
        }
        applyGrowthPhase(phase, to: container)
        return container
    }
}

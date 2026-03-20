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

            let path = CGMutablePath()
            path.move(to: CGPoint(x: -length / 2, y: 0))
            let cp1 = CGPoint(x: -length / 6, y: cellSize.height * 0.05)
            let cp2 = CGPoint(x: length / 6, y: -cellSize.height * 0.05)
            path.addCurve(to: CGPoint(x: length / 2, y: 0), control1: cp1, control2: cp2)

            let line = SKShapeNode(path: path)
            line.strokeColor = MoodType.angry.uiColor
            line.lineWidth = thickness
            line.lineCap = .round
            line.alpha = nextFloat(random, min: 0.5, max: 0.8)
            line.zRotation = angle
            line.position = CGPoint(
                x: nextFloat(random, min: -0.15, max: 0.15) * cellSize.width,
                y: nextFloat(random, min: -0.2, max: 0.2) * cellSize.height
            )

            let drift = nextFloat(random, min: 0.15, max: 0.3) * cellSize.width
            let move = SKAction.sequence([
                SKAction.moveBy(
                    x: drift, y: drift * 0.3, duration: nextFloat(random, min: 0.8, max: 1.2) * speed),
                SKAction.moveBy(
                    x: -drift, y: -drift * 0.3, duration: nextFloat(random, min: 0.8, max: 1.2) * speed),
            ])
            line.run(.repeatForever(move))

            let baseAlpha = line.alpha
            let alphaStrong = min(baseAlpha * 1.3, 1.0)
            let alphaWeak = baseAlpha * 0.4
            let fadeStrong = SKAction.fadeAlpha(
                to: alphaStrong, duration: nextFloat(random, min: 0.8, max: 1.1) * speed)
            fadeStrong.timingMode = .easeInEaseOut
            let fadeWeak = SKAction.fadeAlpha(
                to: alphaWeak, duration: nextFloat(random, min: 0.8, max: 1.3) * speed)
            fadeWeak.timingMode = .easeInEaseOut
            let fadeBase = SKAction.fadeAlpha(
                to: baseAlpha, duration: nextFloat(random, min: 0.8, max: 1.1) * speed)
            fadeBase.timingMode = .easeInEaseOut
            let gust = SKAction.sequence([fadeStrong, fadeWeak, fadeBase])
            line.run(.repeatForever(gust))

            container.addChild(line)
        }
        applyGrowthPhase(phase, to: container)
        return container
    }
}

import GameplayKit
import SpriteKit

struct FogElement: GardenElement {
    func createNode(seed: Int, cellSize: CGSize) -> SKNode {
        let random = makeRandom(seed: seed)
        let container = SKNode()
        let patchCount = 2 + Int(random.nextInt(upperBound: 2))

        for _ in 0..<patchCount {
            let width = nextFloat(random, min: 0.4, max: 0.7) * cellSize.width
            let height = nextFloat(random, min: 0.15, max: 0.3) * cellSize.height
            let fog = SKShapeNode(ellipseOf: CGSize(width: width, height: height))
            fog.fillColor = MoodType.anxious.uiColor
            fog.strokeColor = .clear
            fog.alpha = nextFloat(random, min: 0.2, max: 0.4)

            let startX = nextFloat(random, min: -0.3, max: 0.3) * cellSize.width
            fog.position = CGPoint(
                x: startX,
                y: nextFloat(random, min: -0.2, max: 0.2) * cellSize.height
            )

            // 水平ドリフト + 垂直成分追加
            let driftX = nextFloat(random, min: 0.1, max: 0.2) * cellSize.width
            let driftY = nextFloat(random, min: 0.03, max: 0.07) * cellSize.height
            let moveDuration1 = nextFloat(random, min: 1.2, max: 1.5)
            let moveDuration2 = nextFloat(random, min: 1.2, max: 1.5)
            let move = SKAction.sequence([
                SKAction.moveBy(x: driftX, y: driftY, duration: moveDuration1),
                SKAction.moveBy(x: -driftX, y: -driftY, duration: moveDuration2),
            ])
            fog.run(.repeatForever(move))

            // alpha 緩やか変動
            let baseAlpha = fog.alpha
            let alphaLow = baseAlpha * 0.6
            let fadeDuration = nextFloat(random, min: 1.0, max: 1.5)
            let alphaFade = SKAction.sequence([
                SKAction.fadeAlpha(to: alphaLow, duration: fadeDuration),
                SKAction.fadeAlpha(to: baseAlpha, duration: fadeDuration),
            ])
            alphaFade.timingMode = .easeInEaseOut
            fog.run(.repeatForever(alphaFade))

            container.addChild(fog)
        }
        return container
    }
}

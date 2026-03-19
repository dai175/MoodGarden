import GameplayKit
import SpriteKit

struct RainElement: GardenElement {
    func createNode(seed: Int, cellSize: CGSize) -> SKNode {
        let random = makeRandom(seed: seed)
        let container = SKNode()
        let dropCount = 3 + Int(random.nextInt(upperBound: 3))

        for _ in 0..<dropCount {
            let dropX = nextFloat(random, min: -0.35, max: 0.35) * cellSize.width
            let lineHeight = nextFloat(random, min: 0.15, max: 0.3) * cellSize.height

            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: lineHeight / 2))
            path.addLine(to: CGPoint(x: 0, y: -lineHeight / 2))

            let drop = SKShapeNode(path: path)
            drop.strokeColor = MoodType.sad.uiColor
            // 太さバリエーション
            drop.lineWidth = nextFloat(random, min: 1.0, max: 2.5)
            drop.alpha = nextFloat(random, min: 0.5, max: 0.8)
            drop.position = CGPoint(x: dropX, y: cellSize.height * 0.2)

            let fallDistance = cellSize.height * 0.5
            let duration = nextFloat(random, min: 0.8, max: 1.2)

            // 着地リプル: 落下終端でスケールパルス
            let rippleScale = SKAction.scale(to: 1.4, duration: 0.8)
            let rippleRestore = SKAction.scale(to: 1.0, duration: 0.8)
            rippleScale.timingMode = .easeInEaseOut
            rippleRestore.timingMode = .easeInEaseOut

            let fall = SKAction.sequence([
                SKAction.moveBy(x: 0, y: -fallDistance, duration: duration),
                rippleScale,
                rippleRestore,
                SKAction.fadeOut(withDuration: 0.8),
                SKAction.move(to: CGPoint(x: dropX, y: cellSize.height * 0.2), duration: 0),
                SKAction.fadeAlpha(to: drop.alpha, duration: 0.8),
            ])
            drop.run(.repeatForever(fall))

            container.addChild(drop)
        }

        let puddleWidth = nextFloat(random, min: 0.3, max: 0.5) * cellSize.width
        let puddle = SKShapeNode(ellipseOf: CGSize(width: puddleWidth, height: puddleWidth * 0.25))
        puddle.fillColor = MoodType.sad.uiColor
        puddle.strokeColor = .clear
        puddle.alpha = 0.3
        puddle.position = CGPoint(x: 0, y: -cellSize.height * 0.3)
        container.addChild(puddle)

        return container
    }
}

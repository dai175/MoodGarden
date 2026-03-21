import GameplayKit
import SpriteKit
import UIKit

struct RainbowElement: GardenElement {
    let elementType = ElementType.rainbow
    let preferredZone = PlacementZone.sky
    let estimatedNodes = 5

    func createNode(seed: Int, phase: GrowthPhase, sceneSize: CGSize) -> SKNode {
        let random = makeRandom(seed: seed)
        let cellSize = refSize(from: sceneSize)
        let speed = animationSpeed(for: phase)
        let container = SKNode()

        let arcColors: [UIColor] = [
            MoodType.angry.uiColor,
            MoodType.happy.uiColor,
            MoodType.energetic.uiColor,
            MoodType.peaceful.uiColor,
            MoodType.sad.uiColor,
        ]

        let bandCount = 3 + Int(random.nextInt(upperBound: 3))
        let baseRadius = nextFloat(random, min: 0.25, max: 0.4) * cellSize.width
        let bandSpacing = nextFloat(random, min: 0.02, max: 0.035) * cellSize.width

        for index in 0..<bandCount {
            let radius = baseRadius + bandSpacing * CGFloat(index)
            let arcPath = CGMutablePath()
            arcPath.addArc(
                center: .zero,
                radius: radius,
                startAngle: .pi,
                endAngle: 0,
                clockwise: false
            )

            let arc = SKShapeNode(path: arcPath)
            let colorIndex = index % arcColors.count
            arc.strokeColor = arcColors[colorIndex]
            arc.lineWidth = nextFloat(random, min: 1.0, max: 2.0)
            arc.fillColor = .clear
            arc.alpha = nextFloat(random, min: 0.25, max: 0.45)

            // Gentle fade in/out cycle
            let baseAlpha = arc.alpha
            let fadeDuration = nextFloat(random, min: 2.5, max: 4.0) * speed
            let arcPulse = pulseAlpha(
                from: min(baseAlpha * 1.4, 0.7), to: baseAlpha * 0.4, duration: fadeDuration)
            let phaseDelay = SKAction.wait(forDuration: Double(index) * 0.3)
            arc.run(.sequence([phaseDelay, .repeatForever(arcPulse)]))

            container.addChild(arc)
        }

        applyGrowthPhase(phase, to: container)
        return container
    }
}

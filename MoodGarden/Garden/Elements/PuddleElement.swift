import GameplayKit
import SpriteKit

struct PuddleElement: GardenElement {
    let elementType = ElementType.puddle
    let preferredZone = PlacementZone.waterside
    let estimatedNodes = 2

    func createNode(seed: Int, phase: GrowthPhase, sceneSize: CGSize) -> SKNode {
        let random = makeRandom(seed: seed)
        let cellSize = refSize(from: sceneSize)
        let speed = animationSpeed(for: phase)
        let container = SKNode()

        // Main puddle — flat ellipse
        let puddleWidth = nextFloat(random, min: 0.35, max: 0.55) * cellSize.width
        let puddleHeight = puddleWidth * nextFloat(random, min: 0.25, max: 0.35)
        let puddle = SKShapeNode(ellipseOf: CGSize(width: puddleWidth, height: puddleHeight))
        puddle.fillColor = MoodType.sad.uiColor
        puddle.strokeColor = .clear
        puddle.alpha = nextFloat(random, min: 0.35, max: 0.55)
        container.addChild(puddle)

        // Alpha ripple — shimmer effect
        let baseAlpha = puddle.alpha
        let rippleDuration = nextFloat(random, min: 1.5, max: 2.5) * speed
        puddle.run(
            .repeatForever(
                pulseAlpha(from: min(baseAlpha * 1.5, 0.7), to: baseAlpha * 0.6, duration: rippleDuration)
            ))

        // Shimmer highlight — small bright spot
        let shimmerSize = puddleWidth * nextFloat(random, min: 0.15, max: 0.25)
        let shimmer = SKShapeNode(ellipseOf: CGSize(width: shimmerSize, height: shimmerSize * 0.5))
        shimmer.fillColor = .white
        shimmer.strokeColor = .clear
        shimmer.alpha = 0.15
        shimmer.position = CGPoint(
            x: nextFloat(random, min: -0.1, max: 0.1) * puddleWidth,
            y: puddleHeight * 0.15
        )
        shimmer.zPosition = 1

        shimmer.run(.repeatForever(pulseAlpha(from: 0.3, to: 0.1, duration: 1.8 * speed)))

        container.addChild(shimmer)

        applyGrowthPhase(phase, to: container)
        return container
    }
}

import SpriteKit
import UIKit

enum TransitionDirector {

    static let fogNodeName = "transitionFog"

    static func makeFogOverlay(
        sceneSize: CGSize, fillColor: UIColor, alpha: CGFloat = 0
    ) -> SKShapeNode {
        let rect = CGRect(
            x: -sceneSize.width / 2,
            y: -sceneSize.height / 2,
            width: sceneSize.width,
            height: sceneSize.height
        )
        let overlay = SKShapeNode(rect: rect)
        overlay.name = fogNodeName
        overlay.fillColor = fillColor
        overlay.strokeColor = .clear
        overlay.alpha = alpha
        overlay.zPosition = 100
        return overlay
    }

    static func duration(totalRecords: Int) -> TimeInterval {
        switch totalRecords {
        case 0...10: return 1.5
        case 11...30: return 1.3
        default: return 1.0
        }
    }

    static func runTransition(
        on scene: SKScene,
        mood: MoodType,
        totalRecords: Int,
        completion: @escaping () -> Void
    ) {
        let total = duration(totalRecords: totalRecords)
        let pauseDuration: TimeInterval = 0.3
        let remaining = total - pauseDuration
        let fogRiseDuration = remaining * 0.4
        let fogClearDuration = remaining * 0.6

        // Phase 1: Pause — slow down scene
        let originalSpeed = scene.speed
        scene.speed = 0.3

        // Create fog overlay
        let fogOverlay = makeFogOverlay(
            sceneSize: scene.size,
            fillColor: mood.uiColor.withAlphaComponent(0.3)
        )
        scene.addChild(fogOverlay)

        // Phase 2: Fog rise — after pause
        let waitForPause = SKAction.wait(forDuration: pauseDuration)
        let fogRise = SKAction.fadeAlpha(to: 0.6, duration: fogRiseDuration)
        fogRise.timingMode = .easeIn

        // Phase 3: Fog clear — fade out + restore speed
        let fogClear = SKAction.fadeOut(withDuration: fogClearDuration)
        fogClear.timingMode = .easeOut
        let restoreSpeed = SKAction.run { scene.speed = originalSpeed }
        let cleanup = SKAction.removeFromParent()
        let notifyCompletion = SKAction.run { completion() }

        let sequence = SKAction.sequence([
            waitForPause,
            fogRise,
            fogClear,
            restoreSpeed,
            cleanup,
            notifyCompletion,
        ])

        fogOverlay.run(sequence)
    }
}

import SpriteKit
import UIKit

enum TransitionDirector {

    static func duration(totalRecords: Int) -> TimeInterval {
        switch totalRecords {
        case 0...10: return 2.0
        case 11...30: return 1.7
        default: return 1.5
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
        scene.speed = 0.3

        // Create fog overlay
        let fogRect = CGRect(
            x: -scene.size.width / 2,
            y: -scene.size.height / 2,
            width: scene.size.width,
            height: scene.size.height
        )
        let fogOverlay = SKShapeNode(rect: fogRect)
        fogOverlay.name = "transitionFog"
        fogOverlay.fillColor = mood.uiColor.withAlphaComponent(0.3)
        fogOverlay.strokeColor = .clear
        fogOverlay.alpha = 0
        fogOverlay.zPosition = 100
        scene.addChild(fogOverlay)

        // Phase 2: Fog rise — after pause
        let waitForPause = SKAction.wait(forDuration: pauseDuration)
        let fogRise = SKAction.fadeAlpha(to: 0.6, duration: fogRiseDuration)
        fogRise.timingMode = .easeIn

        // Phase 3: Fog clear — fade out + restore speed
        let fogClear = SKAction.fadeOut(withDuration: fogClearDuration)
        fogClear.timingMode = .easeOut
        let restoreSpeed = SKAction.run { scene.speed = 1.0 }
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

import SpriteKit
import UIKit

final class SeasonalLayer: SKNode {

    func configure(season: Season, sceneSize: CGSize) {
        removeAllChildren()
        addOverlay(for: season, sceneSize: sceneSize)
        addParticles(for: season, sceneSize: sceneSize)
    }

    // MARK: - Color Overlay

    private func addOverlay(for season: Season, sceneSize: CGSize) {
        let rect = CGRect(
            x: -sceneSize.width / 2,
            y: -sceneSize.height / 2,
            width: sceneSize.width,
            height: sceneSize.height
        )
        let shape = SKShapeNode(rect: rect)
        shape.strokeColor = .clear
        shape.lineWidth = 0
        shape.fillColor = season.tintColor
        shape.zPosition = 0
        shape.isUserInteractionEnabled = false
        addChild(shape)
    }

    // MARK: - Particles

    private func addParticles(for season: Season, sceneSize: CGSize) {
        let emitter: SKEmitterNode
        switch season {
        case .spring:
            emitter = makeSpringEmitter(sceneSize: sceneSize)
        case .summer:
            emitter = makeSummerEmitter(sceneSize: sceneSize)
        case .autumn:
            emitter = makeAutumnEmitter(sceneSize: sceneSize)
        case .winter:
            emitter = makeWinterEmitter(sceneSize: sceneSize)
        }
        emitter.zPosition = 1
        addChild(emitter)
    }

    // MARK: - Spring: Pink Cherry Blossoms

    private func makeSpringEmitter(sceneSize: CGSize) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.particleTexture = makeCircleTexture(radius: 4, color: .white)
        emitter.particleBirthRate = 2.5
        emitter.particleLifetime = 7
        emitter.particleLifetimeRange = 2
        emitter.particlePositionRange = CGVector(dx: sceneSize.width, dy: 0)
        emitter.position = CGPoint(x: 0, y: sceneSize.height / 2)
        emitter.particleSpeed = 30
        emitter.particleSpeedRange = 10
        emitter.emissionAngle = -.pi / 2
        emitter.emissionAngleRange = .pi / 8
        emitter.xAcceleration = 8
        emitter.particleAlpha = 0.75
        emitter.particleAlphaRange = 0.2
        emitter.particleAlphaSpeed = -0.08
        emitter.particleScale = 0.6
        emitter.particleScaleRange = 0.3
        emitter.particleRotation = 0
        emitter.particleRotationRange = .pi
        emitter.particleRotationSpeed = 0.5
        emitter.particleColor = UIColor(red: 1.0, green: 0.75, blue: 0.85, alpha: 1.0)
        emitter.particleColorBlendFactor = 1.0
        return emitter
    }

    // MARK: - Summer: Yellow Fireflies

    private func makeSummerEmitter(sceneSize: CGSize) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.particleTexture = makeCircleTexture(radius: 3, color: .white)
        emitter.particleBirthRate = 1.5
        emitter.particleLifetime = 5
        emitter.particleLifetimeRange = 3
        emitter.particlePositionRange = CGVector(dx: sceneSize.width * 0.8, dy: sceneSize.height * 0.6)
        emitter.position = CGPoint(x: 0, y: 0)
        emitter.particleSpeed = 10
        emitter.particleSpeedRange = 8
        emitter.emissionAngle = 0
        emitter.emissionAngleRange = .pi * 2
        emitter.xAcceleration = 0
        emitter.yAcceleration = 0
        emitter.particleAlpha = 0.9
        emitter.particleAlphaRange = 0.3
        emitter.particleAlphaSpeed = -0.15
        emitter.particleScale = 0.5
        emitter.particleScaleRange = 0.2
        emitter.particleColor = UIColor(red: 1.0, green: 0.95, blue: 0.4, alpha: 1.0)
        emitter.particleColorBlendFactor = 1.0
        return emitter
    }

    // MARK: - Autumn: Brown/Orange Falling Leaves

    private func makeAutumnEmitter(sceneSize: CGSize) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.particleTexture = makeLeafTexture()
        emitter.particleBirthRate = 2
        emitter.particleLifetime = 6
        emitter.particleLifetimeRange = 2
        emitter.particlePositionRange = CGVector(dx: sceneSize.width, dy: 0)
        emitter.position = CGPoint(x: 0, y: sceneSize.height / 2)
        emitter.particleSpeed = 35
        emitter.particleSpeedRange = 15
        emitter.emissionAngle = -.pi / 2
        emitter.emissionAngleRange = .pi / 6
        emitter.xAcceleration = 5
        emitter.particleAlpha = 0.8
        emitter.particleAlphaRange = 0.2
        emitter.particleAlphaSpeed = -0.1
        emitter.particleScale = 0.7
        emitter.particleScaleRange = 0.4
        emitter.particleRotation = 0
        emitter.particleRotationRange = .pi * 2
        emitter.particleRotationSpeed = 1.2
        emitter.particleColor = UIColor(red: 0.85, green: 0.45, blue: 0.1, alpha: 1.0)
        emitter.particleColorBlendFactor = 1.0
        return emitter
    }

    // MARK: - Winter: White Snow

    private func makeWinterEmitter(sceneSize: CGSize) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.particleTexture = makeCircleTexture(radius: 3, color: .white)
        emitter.particleBirthRate = 3.5
        emitter.particleLifetime = 8
        emitter.particleLifetimeRange = 2
        emitter.particlePositionRange = CGVector(dx: sceneSize.width * 1.2, dy: 0)
        emitter.position = CGPoint(x: 0, y: sceneSize.height / 2)
        emitter.particleSpeed = 20
        emitter.particleSpeedRange = 8
        emitter.emissionAngle = -.pi / 2
        emitter.emissionAngleRange = .pi / 10
        emitter.xAcceleration = 3
        emitter.particleAlpha = 0.7
        emitter.particleAlphaRange = 0.2
        emitter.particleAlphaSpeed = -0.06
        emitter.particleScale = 0.4
        emitter.particleScaleRange = 0.3
        emitter.particleColor = UIColor(red: 0.9, green: 0.95, blue: 1.0, alpha: 1.0)
        emitter.particleColorBlendFactor = 1.0
        return emitter
    }

    // MARK: - Texture Helpers

    private func makeCircleTexture(radius: CGFloat, color: UIColor) -> SKTexture {
        let diameter = radius * 2
        let size = CGSize(width: diameter, height: diameter)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            color.setFill()
            context.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
        }
        return SKTexture(image: image)
    }

    private func makeLeafTexture() -> SKTexture {
        let size = CGSize(width: 10, height: 8)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let cgContext = context.cgContext
            cgContext.setFillColor(UIColor.white.cgColor)
            cgContext.move(to: CGPoint(x: 5, y: 0))
            cgContext.addQuadCurve(to: CGPoint(x: 10, y: 4), control: CGPoint(x: 10, y: 0))
            cgContext.addQuadCurve(to: CGPoint(x: 5, y: 8), control: CGPoint(x: 10, y: 8))
            cgContext.addQuadCurve(to: CGPoint(x: 0, y: 4), control: CGPoint(x: 0, y: 8))
            cgContext.addQuadCurve(to: CGPoint(x: 5, y: 0), control: CGPoint(x: 0, y: 0))
            cgContext.fillPath()
        }
        return SKTexture(image: image)
    }
}

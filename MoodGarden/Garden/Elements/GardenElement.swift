import GameplayKit
import SpriteKit
import UIKit

protocol GardenElement {
    var elementType: ElementType { get }
    var preferredZone: PlacementZone { get }
    var estimatedNodes: Int { get }

    func createNode(seed: Int, phase: GrowthPhase, sceneSize: CGSize) -> SKNode
}

extension GardenElement {
    func makeRandom(seed: Int) -> GKMersenneTwisterRandomSource {
        GKMersenneTwisterRandomSource(seed: UInt64(bitPattern: Int64(seed)))
    }

    func nextFloat(_ random: GKMersenneTwisterRandomSource, min: Float, max: Float) -> CGFloat {
        CGFloat(random.nextUniform() * (max - min) + min)
    }

    /// Reference size derived from scene size (replaces former cellSize).
    func refSize(from sceneSize: CGSize) -> CGSize {
        CGSize(width: sceneSize.width / 8, height: sceneSize.height / 6)
    }

    /// Apply growth phase scale and alpha to a node.
    func applyGrowthPhase(_ phase: GrowthPhase, to node: SKNode) {
        node.setScale(phase.scale)
        node.alpha *= phase.alpha * 0.85
    }

    /// Scale animation durations by growth phase (mature elements animate slower).
    func animationSpeed(for phase: GrowthPhase) -> CGFloat {
        switch phase {
        case .seed: return 0.9
        case .sprout: return 1.0
        case .bloom: return 1.0
        case .mature: return 1.3
        }
    }

    // MARK: - Common Animation Helpers

    /// Alpha fade/pulse cycle (easeInEaseOut). Returns a single cycle; wrap in `.repeatForever()`.
    func pulseAlpha(from high: CGFloat, to low: CGFloat, duration: CGFloat) -> SKAction {
        let fadeDown = SKAction.fadeAlpha(to: low, duration: duration)
        fadeDown.timingMode = .easeInEaseOut
        let fadeUp = SKAction.fadeAlpha(to: high, duration: duration)
        fadeUp.timingMode = .easeInEaseOut
        return .sequence([fadeDown, fadeUp])
    }

    /// Bidirectional drift movement cycle. Returns a single cycle; wrap in `.repeatForever()`.
    func driftAction(dx: CGFloat, dy: CGFloat, duration: CGFloat) -> SKAction {
        .sequence([
            SKAction.moveBy(x: dx, y: dy, duration: duration),
            SKAction.moveBy(x: -dx, y: -dy, duration: duration),
        ])
    }

    /// Symmetric sway rotation cycle (easeInEaseOut). Returns a single cycle; wrap in `.repeatForever()`.
    func swayRotation(angle: CGFloat, duration: CGFloat) -> SKAction {
        let forward = SKAction.rotate(byAngle: angle, duration: duration / 2)
        forward.timingMode = .easeInEaseOut
        let backward = SKAction.rotate(byAngle: -angle, duration: duration / 2)
        backward.timingMode = .easeInEaseOut
        return .sequence([forward, backward])
    }

    // MARK: - Soft-Edge Texture Helpers

    /// Create a soft-edged circle sprite with radial alpha fade.
    func makeSoftCircle(radius: CGFloat, color: UIColor, softness: CGFloat = 0.3) -> SKSpriteNode {
        let diameter = radius * 2
        let size = CGSize(width: diameter, height: diameter)
        let texture = makeSoftTexture(size: size, isCircle: true, color: color, softness: softness)
        return SKSpriteNode(texture: texture, size: size)
    }

    /// Create a soft-edged ellipse sprite with radial alpha fade.
    func makeSoftEllipse(size: CGSize, color: UIColor, softness: CGFloat = 0.3) -> SKSpriteNode {
        let texture = makeSoftTexture(size: size, isCircle: false, color: color, softness: softness)
        return SKSpriteNode(texture: texture, size: size)
    }

    /// Create a soft-edged ellipse sprite with glow baked into the texture.
    func makeSoftEllipseWithGlow(
        size: CGSize, color: UIColor, softness: CGFloat = 0.3, glowRadius: CGFloat = 4,
        glowColor: UIColor? = nil
    ) -> SKSpriteNode {
        let padding = glowRadius * 2
        let textureSize = CGSize(width: size.width + padding, height: size.height + padding)
        let renderer = UIGraphicsImageRenderer(size: textureSize)
        let image = renderer.image { context in
            let cgContext = context.cgContext
            let ellipseRect = CGRect(
                x: padding / 2, y: padding / 2,
                width: size.width, height: size.height
            )
            let glow = glowColor ?? color.withAlphaComponent(0.6)
            cgContext.setShadow(offset: .zero, blur: glowRadius, color: glow.cgColor)
            drawSoftEllipse(in: cgContext, rect: ellipseRect, color: color, softness: softness)
        }
        let texture = SKTexture(image: image)
        return SKSpriteNode(texture: texture, size: textureSize)
    }

    private func makeSoftTexture(
        size: CGSize, isCircle: Bool, color: UIColor, softness: CGFloat
    ) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let cgContext = context.cgContext
            let rect = CGRect(origin: .zero, size: size)
            drawSoftEllipse(in: cgContext, rect: rect, color: color, softness: softness)
        }
        return SKTexture(image: image)
    }

    private func drawSoftEllipse(
        in cgContext: CGContext, rect: CGRect, color: UIColor, softness: CGFloat
    ) {
        let centerX = rect.midX
        let centerY = rect.midY
        let radiusX = rect.width / 2
        let radiusY = rect.height / 2
        let maxRadius = max(radiusX, radiusY)

        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let innerStop = max(0, 1.0 - softness)
        let colors = [
            CGColor(colorSpace: colorSpace, components: [r, g, b, a])!,
            CGColor(colorSpace: colorSpace, components: [r, g, b, a])!,
            CGColor(colorSpace: colorSpace, components: [r, g, b, 0])!,
        ]
        let locations: [CGFloat] = [0, innerStop, 1.0]

        guard
            let gradient = CGGradient(
                colorsSpace: colorSpace, colors: colors as CFArray, locations: locations)
        else { return }

        // Scale context to handle elliptical shape
        cgContext.saveGState()
        cgContext.translateBy(x: centerX, y: centerY)
        cgContext.scaleBy(x: radiusX / maxRadius, y: radiusY / maxRadius)
        cgContext.drawRadialGradient(
            gradient,
            startCenter: .zero, startRadius: 0,
            endCenter: .zero, endRadius: maxRadius,
            options: []
        )
        cgContext.restoreGState()
    }
}

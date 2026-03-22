import GameplayKit
import SpriteKit
import UIKit

/// Alpha compensation for soft-edge textures vs former SKShapeNode rendering.
private let textureAlphaCompensation: CGFloat = 0.85

/// Cache for soft-edge textures, keyed by quantized size + color + softness.
private let softTextureCache = SoftTextureCache()

private final class SoftTextureCache: @unchecked Sendable {
    private let lock = NSLock()
    private var cache: [String: SKTexture] = [:]

    /// Round to 4px grid for cache-friendly bucketing.
    private func quantize(_ value: CGFloat) -> Int {
        Int(ceil(value / 4) * 4)
    }

    private func colorHex(_ color: UIColor) -> UInt32 {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        color.getRed(&r, green: &g, blue: &b, alpha: &a)
        let ri = UInt32(r * 255) & 0xFF
        let gi = UInt32(g * 255) & 0xFF
        let bi = UInt32(b * 255) & 0xFF
        let ai = UInt32(a * 255) & 0xFF
        return (ri << 24) | (gi << 16) | (bi << 8) | ai
    }

    func texture(
        size: CGSize, color: UIColor, softness: CGFloat,
        suffix: String = "",
        generator: (CGSize) -> SKTexture
    ) -> (texture: SKTexture, quantizedSize: CGSize) {
        let qw = quantize(size.width)
        let qh = quantize(size.height)
        let key = "\(qw)x\(qh)_\(colorHex(color))_\(Int(softness * 100))\(suffix)"
        let qSize = CGSize(width: qw, height: qh)
        lock.lock()
        if let cached = cache[key] {
            lock.unlock()
            return (cached, qSize)
        }
        let tex = generator(qSize)
        cache[key] = tex
        lock.unlock()
        return (tex, qSize)
    }
}

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
    /// Set `isImageSprite` to `true` for image-based sprites that don't need soft-edge alpha compensation.
    func applyGrowthPhase(_ phase: GrowthPhase, to node: SKNode, isImageSprite: Bool = false) {
        node.setScale(phase.scale)
        node.alpha *= phase.alpha * (isImageSprite ? 1.0 : textureAlphaCompensation)
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

    // MARK: - Image-Based Sprite Helper

    /// Create a sprite node from an asset catalog image, sized relative to the scene.
    /// `widthFraction` controls how wide the sprite is relative to `refSize.width`.
    func makeImageSprite(
        named imageName: String, sceneSize: CGSize, widthFraction: CGFloat = 0.8
    ) -> SKSpriteNode {
        let texture = SKTexture(imageNamed: imageName)
        let cell = refSize(from: sceneSize)
        let targetWidth = cell.width * widthFraction
        let aspectRatio = texture.size().height / texture.size().width
        let targetHeight = targetWidth * aspectRatio
        let sprite = SKSpriteNode(texture: texture, size: CGSize(width: targetWidth, height: targetHeight))
        return sprite
    }

    // MARK: - Soft-Edge Texture Helpers

    /// Create a soft-edged circle sprite with radial alpha fade.
    func makeSoftCircle(radius: CGFloat, color: UIColor, softness: CGFloat = 0.3) -> SKSpriteNode {
        let diameter = radius * 2
        let size = CGSize(width: diameter, height: diameter)
        let texture = makeSoftTexture(size: size, color: color, softness: softness)
        return SKSpriteNode(texture: texture, size: size)
    }

    /// Create a soft-edged ellipse sprite with radial alpha fade.
    func makeSoftEllipse(size: CGSize, color: UIColor, softness: CGFloat = 0.3) -> SKSpriteNode {
        let texture = makeSoftTexture(size: size, color: color, softness: softness)
        return SKSpriteNode(texture: texture, size: size)
    }

    /// Create a soft-edged ellipse sprite with glow baked into the texture.
    func makeSoftEllipseWithGlow(
        size: CGSize, color: UIColor, softness: CGFloat = 0.3, glowRadius: CGFloat = 4,
        glowColor: UIColor? = nil
    ) -> SKSpriteNode {
        let padding = glowRadius * 2
        let textureSize = CGSize(width: size.width + padding, height: size.height + padding)
        let suffix = "_glow\(Int(glowRadius))"
        let (texture, _) = softTextureCache.texture(
            size: textureSize, color: color, softness: softness, suffix: suffix
        ) { qSize in
            let renderer = UIGraphicsImageRenderer(size: qSize)
            let image = renderer.image { context in
                let cgContext = context.cgContext
                let ellipseRect = CGRect(
                    x: padding / 2, y: padding / 2,
                    width: qSize.width - padding, height: qSize.height - padding
                )
                let glow = glowColor ?? color.withAlphaComponent(0.6)
                cgContext.setShadow(offset: .zero, blur: glowRadius, color: glow.cgColor)
                self.drawSoftEllipse(
                    in: cgContext, rect: ellipseRect, color: color, softness: softness)
            }
            return SKTexture(image: image)
        }
        return SKSpriteNode(texture: texture, size: textureSize)
    }

    private func makeSoftTexture(
        size: CGSize, color: UIColor, softness: CGFloat
    ) -> SKTexture {
        let (texture, _) = softTextureCache.texture(
            size: size, color: color, softness: softness
        ) { qSize in
            let renderer = UIGraphicsImageRenderer(size: qSize)
            let image = renderer.image { context in
                let cgContext = context.cgContext
                let rect = CGRect(origin: .zero, size: qSize)
                self.drawSoftEllipse(in: cgContext, rect: rect, color: color, softness: softness)
            }
            return SKTexture(image: image)
        }
        return texture
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

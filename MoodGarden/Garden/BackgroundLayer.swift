import SpriteKit
import UIKit

final class BackgroundLayer: SKNode {
    private let backgroundNode = SKSpriteNode()
    private var lastSeason: Season?
    private var lastSceneSize: CGSize = .zero

    override init() {
        super.init()
        addChild(backgroundNode)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(season: Season, sceneSize: CGSize) {
        let needsUpdate = lastSeason != season || lastSceneSize != sceneSize
        guard needsUpdate else { return }
        lastSeason = season
        lastSceneSize = sceneSize
        applyBackground(season: season, sceneSize: sceneSize)
        startParallax()
    }

    func applyHueShift(_ shift: Float) {
        let colorBlend = CGFloat(abs(shift))
        let tintColor =
            shift >= 0
            ? UIColor(red: 1.0, green: 0.85, blue: 0.6, alpha: 1.0)
            : UIColor(red: 0.6, green: 0.7, blue: 1.0, alpha: 1.0)
        backgroundNode.colorBlendFactor = colorBlend * 0.15
        backgroundNode.color = tintColor
    }

    // MARK: - Background

    private func applyBackground(season: Season, sceneSize: CGSize) {
        let textureName = season.backgroundImageName
        if let image = UIImage(named: textureName) {
            backgroundNode.texture = SKTexture(image: image)
            backgroundNode.size = sceneSize
            backgroundNode.position = .zero
            backgroundNode.zPosition = 0
        } else {
            applyGradientFallback(season: season, sceneSize: sceneSize)
        }
    }

    private func applyGradientFallback(season: Season, sceneSize: CGSize) {
        let colors = season.gradientColors
        backgroundNode.texture = makeGradientTexture(
            size: sceneSize, topColor: colors.top, bottomColor: colors.bottom)
        backgroundNode.size = sceneSize
        backgroundNode.position = .zero
        backgroundNode.zPosition = 0
    }

    private func makeGradientTexture(size: CGSize, topColor: UIColor, bottomColor: UIColor)
        -> SKTexture
    {
        let drawSize = CGSize(width: max(size.width, 1), height: max(size.height, 1))
        let renderer = UIGraphicsImageRenderer(size: drawSize)
        let image = renderer.image { context in
            let cgContext = context.cgContext
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let colors = [topColor.cgColor, bottomColor.cgColor] as CFArray
            guard
                let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: [0, 1])
            else { return }
            cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: drawSize.width / 2, y: 0),
                end: CGPoint(x: drawSize.width / 2, y: drawSize.height),
                options: []
            )
        }
        return SKTexture(image: image)
    }

    // MARK: - Parallax

    private func startParallax() {
        backgroundNode.removeAllActions()
        let drift = SKAction.sequence([
            SKAction.moveBy(x: 3, y: 0, duration: 5),
            SKAction.moveBy(x: -3, y: 0, duration: 5),
        ])
        backgroundNode.run(.repeatForever(drift))
    }
}

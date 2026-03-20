import SpriteKit
import UIKit

final class BackgroundLayer: SKNode {
    private let skyNode = SKSpriteNode()
    private let hillsNode = SKSpriteNode()
    private let groundNode = SKSpriteNode()

    override init() {
        super.init()
        addChild(skyNode)
        addChild(hillsNode)
        addChild(groundNode)
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(season: Season, sceneSize: CGSize) {
        layoutNodes(sceneSize: sceneSize)
        applyTextures(season: season, sceneSize: sceneSize)
        startParallax()
    }

    func applyHueShift(_ shift: Float) {
        let colorBlend = CGFloat(abs(shift))
        let tintColor =
            shift >= 0
            ? UIColor(red: 1.0, green: 0.85, blue: 0.6, alpha: 1.0)  // warm
            : UIColor(red: 0.6, green: 0.7, blue: 1.0, alpha: 1.0)  // cool
        skyNode.colorBlendFactor = colorBlend * 0.3
        skyNode.color = tintColor
        hillsNode.colorBlendFactor = colorBlend * 0.2
        hillsNode.color = tintColor
        groundNode.colorBlendFactor = colorBlend * 0.15
        groundNode.color = tintColor
    }

    // MARK: - Layout

    private func layoutNodes(sceneSize: CGSize) {
        let skyHeight = sceneSize.height * 0.5
        let hillsHeight = sceneSize.height * 0.3
        let groundHeight = sceneSize.height * 0.2

        skyNode.size = CGSize(width: sceneSize.width + 4, height: skyHeight)
        skyNode.position = CGPoint(x: 0, y: sceneSize.height / 2 - skyHeight / 2)
        skyNode.zPosition = 0

        hillsNode.size = CGSize(width: sceneSize.width + 8, height: hillsHeight)
        hillsNode.position = CGPoint(x: 0, y: -sceneSize.height * 0.1)
        hillsNode.zPosition = 1

        groundNode.size = CGSize(width: sceneSize.width, height: groundHeight)
        groundNode.position = CGPoint(x: 0, y: -sceneSize.height / 2 + groundHeight / 2)
        groundNode.zPosition = 2
    }

    // MARK: - Textures

    private func applyTextures(season: Season, sceneSize: CGSize) {
        let colors = seasonColors(for: season)
        skyNode.texture = makeGradientTexture(
            size: skyNode.size, topColor: colors.skyTop, bottomColor: colors.skyBottom)
        hillsNode.texture = makeGradientTexture(
            size: hillsNode.size, topColor: colors.hillTop, bottomColor: colors.hillBottom)
        groundNode.texture = makeGradientTexture(
            size: groundNode.size, topColor: colors.groundTop, bottomColor: colors.groundBottom)
    }

    private struct SeasonColors {
        let skyTop: UIColor
        let skyBottom: UIColor
        let hillTop: UIColor
        let hillBottom: UIColor
        let groundTop: UIColor
        let groundBottom: UIColor
    }

    private func seasonColors(for season: Season) -> SeasonColors {
        switch season {
        case .spring:
            return SeasonColors(
                skyTop: UIColor(red: 0.06, green: 0.12, blue: 0.10, alpha: 1.0),
                skyBottom: UIColor(red: 0.08, green: 0.16, blue: 0.12, alpha: 1.0),
                hillTop: UIColor(red: 0.06, green: 0.14, blue: 0.08, alpha: 1.0),
                hillBottom: UIColor(red: 0.05, green: 0.12, blue: 0.07, alpha: 1.0),
                groundTop: UIColor(red: 0.04, green: 0.10, blue: 0.06, alpha: 1.0),
                groundBottom: UIColor(red: 0.04, green: 0.08, blue: 0.05, alpha: 1.0)
            )
        case .summer:
            return SeasonColors(
                skyTop: UIColor(red: 0.06, green: 0.10, blue: 0.08, alpha: 1.0),
                skyBottom: UIColor(red: 0.07, green: 0.14, blue: 0.10, alpha: 1.0),
                hillTop: UIColor(red: 0.06, green: 0.13, blue: 0.07, alpha: 1.0),
                hillBottom: UIColor(red: 0.05, green: 0.11, blue: 0.06, alpha: 1.0),
                groundTop: UIColor(red: 0.05, green: 0.10, blue: 0.06, alpha: 1.0),
                groundBottom: UIColor(red: 0.04, green: 0.09, blue: 0.05, alpha: 1.0)
            )
        case .autumn:
            return SeasonColors(
                skyTop: UIColor(red: 0.07, green: 0.10, blue: 0.09, alpha: 1.0),
                skyBottom: UIColor(red: 0.08, green: 0.12, blue: 0.10, alpha: 1.0),
                hillTop: UIColor(red: 0.07, green: 0.11, blue: 0.07, alpha: 1.0),
                hillBottom: UIColor(red: 0.06, green: 0.10, blue: 0.06, alpha: 1.0),
                groundTop: UIColor(red: 0.05, green: 0.09, blue: 0.05, alpha: 1.0),
                groundBottom: UIColor(red: 0.04, green: 0.08, blue: 0.05, alpha: 1.0)
            )
        case .winter:
            return SeasonColors(
                skyTop: UIColor(red: 0.05, green: 0.08, blue: 0.12, alpha: 1.0),
                skyBottom: UIColor(red: 0.06, green: 0.10, blue: 0.14, alpha: 1.0),
                hillTop: UIColor(red: 0.05, green: 0.09, blue: 0.11, alpha: 1.0),
                hillBottom: UIColor(red: 0.04, green: 0.08, blue: 0.10, alpha: 1.0),
                groundTop: UIColor(red: 0.04, green: 0.07, blue: 0.09, alpha: 1.0),
                groundBottom: UIColor(red: 0.03, green: 0.06, blue: 0.08, alpha: 1.0)
            )
        }
    }

    private func makeGradientTexture(size: CGSize, topColor: UIColor, bottomColor: UIColor) -> SKTexture {
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
        skyNode.removeAllActions()
        hillsNode.removeAllActions()

        let skyDrift = SKAction.sequence([
            SKAction.moveBy(x: 2, y: 0, duration: 4),
            SKAction.moveBy(x: -2, y: 0, duration: 4),
        ])
        skyNode.run(.repeatForever(skyDrift))

        let hillsDrift = SKAction.sequence([
            SKAction.moveBy(x: 4, y: 0, duration: 5),
            SKAction.moveBy(x: -4, y: 0, duration: 5),
        ])
        hillsNode.run(.repeatForever(hillsDrift))
    }
}

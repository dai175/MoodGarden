import SpriteKit
import UIKit

final class GardenScene: SKScene {
    private let renderer = GardenRenderer()
    private let backgroundLayer = BackgroundLayer()
    private let groundElementsLayer = SKNode()
    private let aerialElementsLayer = SKNode()
    private let seasonalLayer = SeasonalLayer()
    private let atmosphereOverlay = SKShapeNode()

    private var currentState: AtmosphereState = .empty
    private var currentMonth = Calendar.current.component(.month, from: Date())
    private var lastOverlayMonth: Int?

    override init() {
        super.init(size: CGSize(width: 350, height: 250))
        commonInit()
    }

    override init(size: CGSize) {
        super.init(size: size)
        commonInit()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func commonInit() {
        backgroundColor = DesignConstants.Colors.backgroundPrimaryUIColor
        scaleMode = .resizeFill
        anchorPoint = CGPoint(x: 0.5, y: 0.5)

        backgroundLayer.zPosition = 0
        addChild(backgroundLayer)

        groundElementsLayer.zPosition = 10
        addChild(groundElementsLayer)

        aerialElementsLayer.zPosition = 20
        addChild(aerialElementsLayer)

        seasonalLayer.zPosition = 30
        addChild(seasonalLayer)

        atmosphereOverlay.zPosition = 40
        atmosphereOverlay.strokeColor = .clear
        addChild(atmosphereOverlay)
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        isPaused = false
        view.isPaused = false
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard size.width > 0, size.height > 0 else { return }
        let season = Season.from(month: currentMonth)
        backgroundLayer.configure(season: season, sceneSize: size)
        rebuildElements()
        seasonalLayer.configure(season: season, sceneSize: size)
        updateAtmosphereOverlay()
    }

    // MARK: - Public API

    func configureSeason(month: Int) {
        let monthChanged = currentMonth != month
        currentMonth = month
        if monthChanged { lastOverlayMonth = nil }
        let season = Season.from(month: month)
        backgroundLayer.configure(season: season, sceneSize: size)
        seasonalLayer.configure(season: season, sceneSize: size)
        updateAtmosphereOverlay()
    }

    func configure(with state: AtmosphereState) {
        guard state != currentState else { return }
        currentState = state
        rebuildElements()
        updateAtmosphereOverlay()
        backgroundLayer.applyHueShift(state.hueShift)
    }

    func addElements(from specs: [ElementSpec], animated: Bool) {
        guard size.width > 0, size.height > 0 else { return }

        // Merge new specs into currentState so rebuildElements() preserves them
        currentState.elementManifest += specs

        let positions = PlacementRule.computePositions(for: specs, sceneSize: size)
        let nodes = renderer.createNodes(for: specs, positions: positions, sceneSize: size)

        for (index, (node, position)) in nodes.enumerated() {
            let spec = specs[index]
            node.position = position
            let targetLayer = spec.elementType.isGround ? groundElementsLayer : aerialElementsLayer

            if animated {
                node.alpha = 0
                let originalScale = node.xScale
                node.setScale(originalScale * 0.5)
                targetLayer.addChild(node)
                let fadeIn = SKAction.fadeIn(withDuration: 1.2)
                let scaleUp = SKAction.scale(to: originalScale, duration: 1.2)
                fadeIn.timingMode = .easeOut
                scaleUp.timingMode = .easeOut
                node.run(.group([fadeIn, scaleUp]))
            } else {
                targetLayer.addChild(node)
            }
        }

        if animated {
            addFogTransition()
        }
    }

    func performTransition(mood: MoodType, totalRecords: Int, newSpecs: [ElementSpec]) {
        TransitionDirector.runTransition(
            on: self, mood: mood, totalRecords: totalRecords
        ) { [weak self] in
            self?.addElements(from: newSpecs, animated: false)
        }
    }

    // MARK: - Private

    private func rebuildElements() {
        groundElementsLayer.removeAllChildren()
        aerialElementsLayer.removeAllChildren()
        guard size.width > 0, size.height > 0 else { return }

        let specs = currentState.elementManifest
        guard !specs.isEmpty else { return }

        let positions = PlacementRule.computePositions(for: specs, sceneSize: size)
        let nodes = renderer.createNodes(for: specs, positions: positions, sceneSize: size)

        for (index, (node, position)) in nodes.enumerated() {
            node.position = position
            if specs[index].elementType.isGround {
                groundElementsLayer.addChild(node)
            } else {
                aerialElementsLayer.addChild(node)
            }
        }
    }

    private func updateAtmosphereOverlay() {
        guard size.width > 0, size.height > 0 else { return }
        guard lastOverlayMonth != currentMonth else { return }
        lastOverlayMonth = currentMonth
        let season = Season.from(month: currentMonth)
        let rect = CGRect(
            x: -size.width / 2,
            y: -size.height / 2,
            width: size.width,
            height: size.height
        )
        atmosphereOverlay.path = CGPath(rect: rect, transform: nil)
        atmosphereOverlay.fillColor = season.tintColor
        atmosphereOverlay.alpha = 1.0
    }

    private func addFogTransition() {
        if let existing = childNode(withName: TransitionDirector.fogNodeName) {
            existing.removeFromParent()
        }
        let fogOverlay = TransitionDirector.makeFogOverlay(
            sceneSize: size,
            fillColor: DesignConstants.Colors.backgroundPrimaryUIColor,
            alpha: 0.5
        )
        addChild(fogOverlay)

        let fogFade = SKAction.fadeOut(withDuration: 1.0)
        fogFade.timingMode = .easeInEaseOut
        fogOverlay.run(.sequence([fogFade, .removeFromParent()]))
    }
}

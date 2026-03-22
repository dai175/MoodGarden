import SpriteKit
import UIKit

enum ElementAnimation {
    case none
    case fadeIn
    case delayedEntrance
}

final class GardenScene: SKScene {
    private let renderer = GardenRenderer()
    private let backgroundLayer = BackgroundLayer()
    private let groundElementsLayer = SKNode()
    private let aerialElementsLayer = SKNode()
    private let seasonalLayer = SeasonalLayer()
    private let atmosphereOverlay = SKShapeNode()

    private var windState = WindState()
    private var lastUpdateTime: TimeInterval = 0
    private var currentState: AtmosphereState = .empty
    private var currentMonth = Calendar.current.component(.month, from: Date())
    private var currentSeason: Season { Season.from(month: currentMonth) }
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

    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        let deltaTime = lastUpdateTime > 0 ? currentTime - lastUpdateTime : 1.0 / 60.0
        lastUpdateTime = currentTime
        windState.update(currentTime: currentTime)
        applyWind(deltaTime: deltaTime)
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard size.width > 0, size.height > 0 else { return }
        backgroundLayer.configure(season: currentSeason, sceneSize: size)
        rebuildElements()
        seasonalLayer.configure(season: currentSeason, sceneSize: size)
        updateAtmosphereOverlay()
    }

    // MARK: - Public API

    func configureSeason(month: Int) {
        let monthChanged = currentMonth != month
        currentMonth = month
        if monthChanged { lastOverlayMonth = nil }
        backgroundLayer.configure(season: currentSeason, sceneSize: size)
        seasonalLayer.configure(season: currentSeason, sceneSize: size)
        updateAtmosphereOverlay()
    }

    func configure(with state: AtmosphereState) {
        guard state != currentState else { return }
        currentState = state
        rebuildElements()
        updateAtmosphereOverlay()
        backgroundLayer.applyHueShift(state.hueShift)
    }

    func addElements(from specs: [ElementSpec], animation: ElementAnimation) {
        guard size.width > 0, size.height > 0 else { return }

        // Merge new specs into currentState so rebuildElements() preserves them
        currentState.elementManifest += specs

        let positions = PlacementRule.computePositions(for: specs, sceneSize: size)
        let nodes = renderer.createNodes(for: specs, positions: positions, sceneSize: size)

        for (index, (node, position)) in nodes.enumerated() {
            let spec = specs[index]
            node.position = position
            applyDepthEffect(to: node, spec: spec)
            let targetLayer = spec.elementType.isGround ? groundElementsLayer : aerialElementsLayer

            // Apply seasonal tint to non-ground elements (ground gets tinted via applyDepthEffect)
            if !spec.elementType.isGround {
                applyTintRecursive(to: node, color: currentSeason.tintColor, additionalBlend: 0)
            }

            switch animation {
            case .none:
                targetLayer.addChild(node)

            case .fadeIn:
                let targetAlpha = node.alpha
                let targetScale = node.xScale
                node.alpha = 0
                node.setScale(targetScale * 0.5)
                targetLayer.addChild(node)
                let fadeIn = SKAction.fadeAlpha(to: targetAlpha, duration: 1.2)
                let scaleUp = SKAction.scale(to: targetScale, duration: 1.2)
                fadeIn.timingMode = .easeOut
                scaleUp.timingMode = .easeOut
                node.run(.group([fadeIn, scaleUp]))

            case .delayedEntrance:
                let targetAlpha = node.alpha
                let targetScale = node.xScale
                let seedScale = GrowthPhase.seed.scale * targetScale
                node.alpha = 0
                node.setScale(seedScale)
                targetLayer.addChild(node)
                let delay = SKAction.wait(forDuration: 0.5)
                let fadeIn = SKAction.fadeAlpha(to: targetAlpha, duration: 0.8)
                let grow = SKAction.scale(to: targetScale, duration: 0.8)
                fadeIn.timingMode = .easeOut
                grow.timingMode = .easeOut
                node.run(.sequence([delay, .group([fadeIn, grow])]))
            }
        }

        if animation == .fadeIn {
            addFogTransition()
        }
    }

    func performTransition(mood: MoodType, totalRecords: Int, newSpecs: [ElementSpec]) {
        TransitionDirector.runTransition(
            on: self, mood: mood, totalRecords: totalRecords
        ) { [weak self] in
            self?.addElements(from: newSpecs, animation: .delayedEntrance)
            self?.scheduleSettleAnimation()
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
            let spec = specs[index]
            applyDepthEffect(to: node, spec: spec)
            if spec.elementType.isGround {
                groundElementsLayer.addChild(node)
            } else {
                aerialElementsLayer.addChild(node)
            }
        }

        // Ground elements get tinted via applyDepthEffect (with aerial perspective blend).
        // Only apply seasonal tint to aerial elements here.
        applySeasonalTint(to: aerialElementsLayer)
    }

    private func updateAtmosphereOverlay() {
        guard size.width > 0, size.height > 0 else { return }
        guard lastOverlayMonth != currentMonth else { return }
        lastOverlayMonth = currentMonth
        let rect = CGRect(
            x: -size.width / 2,
            y: -size.height / 2,
            width: size.width,
            height: size.height
        )
        atmosphereOverlay.path = CGPath(rect: rect, transform: nil)
        atmosphereOverlay.fillColor = currentSeason.tintColor
        atmosphereOverlay.alpha = 1.0
    }

    private func applyDepthEffect(to node: SKNode, spec: ElementSpec) {
        // Only apply depth scaling to ground elements; aerial elements (fog, wind, etc.) skip it.
        guard spec.elementType.isGround else { return }

        let depthScale = DepthScale.scale(y: node.position.y, sceneHeight: size.height)
        let depthAlpha = DepthScale.alpha(y: node.position.y, sceneHeight: size.height)
        let depthZ = DepthScale.zOffset(y: node.position.y, sceneHeight: size.height)

        node.xScale *= depthScale
        node.yScale *= depthScale
        node.alpha *= depthAlpha
        node.zPosition += depthZ

        // Aerial perspective: distant elements get additional color blend
        let depth = DepthScale.depthFactor(y: node.position.y, sceneHeight: size.height)
        let aerialBlend = (1.0 - depth) * 0.08  // max +0.08 for farthest elements
        applyTintRecursive(
            to: node,
            color: currentSeason.tintColor,
            additionalBlend: aerialBlend
        )
    }

    // MARK: - Seasonal Tinting

    private func applySeasonalTint(to layer: SKNode) {
        let tint = currentSeason.tintColor
        for child in layer.children {
            applyTintRecursive(to: child, color: tint, additionalBlend: 0)
        }
    }

    private func applyTintRecursive(
        to node: SKNode, color: UIColor, additionalBlend: CGFloat
    ) {
        if let sprite = node as? SKSpriteNode {
            // Use tintColor RGB at full alpha; colorBlendFactor controls blend amount
            var r: CGFloat = 0
            var g: CGFloat = 0
            var b: CGFloat = 0
            color.getRed(&r, green: &g, blue: &b, alpha: nil)
            sprite.color = UIColor(red: r, green: g, blue: b, alpha: 1.0)
            sprite.colorBlendFactor = 0.15 + additionalBlend
        }
        for child in node.children {
            applyTintRecursive(to: child, color: color, additionalBlend: additionalBlend)
        }
    }

    // MARK: - Wind

    private func applyWind(deltaTime: TimeInterval) {
        let strength = windState.strength
        let direction = windState.direction
        let dt = CGFloat(deltaTime * 60)  // normalize to 60fps

        for node in groundElementsLayer.children {
            guard let name = node.name else { continue }

            if name.hasPrefix("element_flower_")
                || name.hasPrefix("element_grass_")
                || name.hasPrefix("element_vine_")
            {
                let phaseOffset = (node.position.x + node.position.y) * 0.01
                let targetRotation =
                    direction * strength * 0.15
                    + sin(phaseOffset) * 0.02
                node.zRotation += (targetRotation - node.zRotation) * 0.05 * dt
            } else if name.hasPrefix("element_fallenLeaf_") {
                node.position.x += direction * strength * 0.2 * dt
            }
        }

        for node in aerialElementsLayer.children {
            guard let name = node.name else { continue }

            if name.hasPrefix("element_fog_") || name.hasPrefix("element_wind_") {
                node.position.x += direction * strength * 0.3 * dt
            } else if name.hasPrefix("element_raindrop_") {
                let targetRotation = direction * strength * 0.1
                node.zRotation += (targetRotation - node.zRotation) * 0.08 * dt
            } else if name.hasPrefix("element_butterfly_") {
                node.position.x += direction * strength * 0.15 * dt
            }
        }
    }

    private func scheduleSettleAnimation() {
        let delay = SKAction.wait(forDuration: 1.5)
        let settle = SKAction.run { [weak self] in
            guard let self else { return }
            for layer in [self.groundElementsLayer, self.aerialElementsLayer] {
                for node in layer.children {
                    let current = node.xScale
                    let squish = SKAction.scale(to: current * 0.97, duration: 0.3)
                    let restore = SKAction.scale(to: current, duration: 0.3)
                    squish.timingMode = .easeInEaseOut
                    restore.timingMode = .easeInEaseOut
                    node.run(.sequence([squish, restore]))
                }
            }
        }
        run(.sequence([delay, settle]))
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

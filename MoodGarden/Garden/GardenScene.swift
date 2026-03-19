import SpriteKit
import UIKit

final class GardenScene: SKScene {
    private let renderer = GardenRenderer()
    private let elementsLayer = SKNode()
    private let seasonalLayer = SeasonalLayer()
    private var currentEntries: [GardenElementData] = []
    private var currentMonth = Calendar.current.component(.month, from: Date())

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
        addChild(elementsLayer)
        seasonalLayer.zPosition = 10
        addChild(seasonalLayer)
    }

    override func didMove(to view: SKView) {
        super.didMove(to: view)
        isPaused = false
        view.isPaused = false
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard size.width > 0, size.height > 0 else { return }
        rebuildElements()
        seasonalLayer.configure(season: Season.from(month: currentMonth), sceneSize: size)
    }

    func configureSeason(month: Int) {
        currentMonth = month
        seasonalLayer.configure(season: Season.from(month: month), sceneSize: size)
    }

    func configure(with entries: [GardenElementData]) {
        guard entries != currentEntries else { return }
        currentEntries = entries
        rebuildElements()
    }

    func addEntry(_ entry: GardenElementData, animated: Bool) {
        currentEntries.append(entry)
        let layout = makeLayout()
        let node = renderer.createNode(for: entry, cellSize: layout.cellSize)
        node.position = layout.position(forDay: entry.day)

        if animated {
            node.alpha = 0
            node.setScale(0.5)
            elementsLayer.addChild(node)
            let fadeIn = SKAction.fadeIn(withDuration: 1.2)
            let scaleUp = SKAction.scale(to: 1.0, duration: 1.2)
            fadeIn.timingMode = .easeOut
            scaleUp.timingMode = .easeOut
            node.run(.group([fadeIn, scaleUp]))

            // 霧が晴れるトランジション（既存のものがあれば除去して再生成）
            if let existing = childNode(withName: "fogTransition") {
                existing.removeFromParent()
            }
            let fogRect = CGRect(
                x: -size.width / 2,
                y: -size.height / 2,
                width: size.width,
                height: size.height
            )
            let fogOverlay = SKShapeNode(rect: fogRect)
            fogOverlay.name = "fogTransition"
            fogOverlay.fillColor = DesignConstants.Colors.backgroundPrimaryUIColor
            fogOverlay.strokeColor = .clear
            fogOverlay.alpha = 0.5
            fogOverlay.zPosition = 100
            addChild(fogOverlay)

            let fogFade = SKAction.fadeOut(withDuration: 1.0)
            fogFade.timingMode = .easeInEaseOut
            fogOverlay.run(.sequence([fogFade, .removeFromParent()]))
        } else {
            elementsLayer.addChild(node)
        }
    }

    private func rebuildElements() {
        elementsLayer.removeAllChildren()
        guard size.width > 0, size.height > 0 else { return }

        let layout = makeLayout()
        let nodes = renderer.createNodes(for: currentEntries, layout: layout)
        for (node, position) in nodes {
            node.position = position
            elementsLayer.addChild(node)
        }
    }

    private func makeLayout() -> GardenGridLayout {
        GardenGridLayout(
            columns: DesignConstants.Layout.gridColumns,
            rows: DesignConstants.Layout.gridRows,
            sceneSize: size,
            spacing: DesignConstants.Layout.cellSpacing
        )
    }
}

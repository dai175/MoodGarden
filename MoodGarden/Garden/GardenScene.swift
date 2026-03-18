import SpriteKit

final class GardenScene: SKScene {
    private let renderer = GardenRenderer()
    private let elementsLayer = SKNode()
    private var currentEntries: [GardenElementData] = []

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
    }

    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        guard size.width > 0, size.height > 0 else { return }
        rebuildElements()
    }

    func configure(with entries: [GardenElementData]) {
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

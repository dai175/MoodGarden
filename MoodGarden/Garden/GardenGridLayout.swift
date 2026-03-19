import CoreGraphics

struct GardenGridLayout {
    let columns: Int
    let rows: Int
    let sceneSize: CGSize
    let spacing: CGFloat

    var cellSize: CGSize {
        let availableWidth = sceneSize.width - spacing * CGFloat(columns - 1)
        let availableHeight = sceneSize.height - spacing * CGFloat(rows - 1)
        let side = min(availableWidth / CGFloat(columns), availableHeight / CGFloat(rows))
        return CGSize(width: side, height: side)
    }

    func position(forDay day: Int) -> CGPoint {
        precondition(day >= 1 && day <= columns * rows, "Day must be between 1 and \(columns * rows)")
        let index = day - 1
        let col = index % columns
        let row = index / columns

        let cell = cellSize
        let gridWidth = CGFloat(columns) * cell.width + CGFloat(columns - 1) * spacing
        let gridHeight = CGFloat(rows) * cell.height + CGFloat(rows - 1) * spacing

        let originX = -gridWidth / 2 + cell.width / 2
        let originY = gridHeight / 2 - cell.height / 2

        let posX = originX + CGFloat(col) * (cell.width + spacing)
        let posY = originY - CGFloat(row) * (cell.height + spacing)

        return CGPoint(x: posX, y: posY)
    }
}

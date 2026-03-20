import Foundation
import SpriteKit
import SwiftData
import UIKit

final class SnapshotService {
    private let snapshotSize = CGSize(width: 350, height: 250)

    func renderSnapshot(state: AtmosphereState, month: Int = 1) -> Data? {
        let scene = GardenScene(size: snapshotSize)
        scene.scaleMode = .aspectFill
        scene.configure(with: state)
        scene.configureSeason(month: month)

        let view = SKView(frame: CGRect(origin: .zero, size: snapshotSize))
        view.presentScene(scene)

        guard let texture = view.texture(from: scene) else { return nil }
        let image = UIImage(cgImage: texture.cgImage())
        return image.pngData()
    }

    func performMonthTransition(
        modelContext: ModelContext,
        previousYear: Int,
        previousMonth: Int,
        entries: [MoodEntry]
    ) -> Bool {
        guard !entries.isEmpty else { return false }

        let year = previousYear
        let month = previousMonth
        var descriptor = FetchDescriptor<MonthlyGarden>(
            predicate: #Predicate { $0.year == year && $0.month == month }
        )
        descriptor.fetchLimit = 1

        let existingGarden: MonthlyGarden?
        do {
            existingGarden = try modelContext.fetch(descriptor).first
        } catch {
            return false
        }

        if let existingGarden, existingGarden.completedAt != nil {
            return false
        }

        let season = Season.from(month: previousMonth)
        let state = AtmosphereEngine.analyze(entries: entries, season: season)

        guard let snapshotData = renderSnapshot(state: state, month: previousMonth) else { return false }

        let garden: MonthlyGarden
        if let existingGarden {
            garden = existingGarden
        } else {
            garden = MonthlyGarden(year: previousYear, month: previousMonth)
            modelContext.insert(garden)
        }
        garden.snapshotImage = snapshotData
        garden.completedAt = Date()

        do {
            try modelContext.save()
            return true
        } catch {
            return false
        }
    }
}

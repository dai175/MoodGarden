import Foundation
import SpriteKit
import SwiftData
import UIKit

final class SnapshotService {
    private let snapshotSize = CGSize(width: 350, height: 250)

    func renderSnapshot(entries: [GardenElementData]) -> Data? {
        let scene = GardenScene(size: snapshotSize)
        scene.scaleMode = .aspectFill
        scene.configure(with: entries)

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

        if let existing = try? modelContext.fetch(descriptor).first,
            existing.completedAt != nil
        {
            return false
        }

        let calendar = Calendar.current
        let elementData = entries.map { entry in
            GardenElementData(
                day: calendar.component(.day, from: entry.date),
                mood: entry.mood,
                seed: entry.gardenSeed
            )
        }

        guard let snapshotData = renderSnapshot(entries: elementData) else { return false }

        let garden: MonthlyGarden
        if let existing = try? modelContext.fetch(descriptor).first {
            garden = existing
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

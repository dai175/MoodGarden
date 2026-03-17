import SwiftData

@testable import MoodGarden

enum TestHelpers {
    static func makeModelContainer() throws -> ModelContainer {
        try ModelContainer(
            for: MoodEntry.self, MonthlyGarden.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }
}

import SwiftData
import SwiftUI

@main
struct MoodGardenApp: App {
    @State private var appState = AppState()
    @State private var notificationService = NotificationService()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            MoodEntry.self,
            MonthlyGarden.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .environment(notificationService)
        }
        .modelContainer(sharedModelContainer)
    }
}

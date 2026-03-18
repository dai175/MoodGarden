import Foundation
import SwiftData

@Observable
final class SettingsViewModel {
    let notificationService: NotificationService
    private var modelContext: ModelContext

    var notificationTime: Date {
        didSet {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from: notificationTime)
            Task {
                await notificationService.updateTime(
                    hour: components.hour ?? 21,
                    minute: components.minute ?? 0
                )
            }
        }
    }

    var notificationEnabled: Bool {
        didSet { notificationService.isEnabled = notificationEnabled }
    }

    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    init(notificationService: NotificationService, modelContext: ModelContext) {
        self.notificationService = notificationService
        self.modelContext = modelContext

        self.notificationEnabled = notificationService.isEnabled

        var components = DateComponents()
        components.hour = notificationService.scheduledHour
        components.minute = notificationService.scheduledMinute
        self.notificationTime = Calendar.current.date(from: components) ?? Date()
    }

    func resetAllData() {
        do {
            try modelContext.delete(model: MoodEntry.self)
            try modelContext.delete(model: MonthlyGarden.self)
            try modelContext.save()
        } catch {
            // Silent failure — data reset is best-effort
        }
    }
}

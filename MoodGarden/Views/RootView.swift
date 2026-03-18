import SwiftData
import SwiftUI

struct RootView: View {
    @Environment(AppState.self) private var appState
    @Environment(NotificationService.self) private var notificationService
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase

    @State private var viewModel: GardenViewModel?
    @State private var showArchive = false
    @State private var showSettings = false
    @State private var showMonthTransitionToast = false

    var body: some View {
        Group {
            if !appState.hasCompletedOnboarding {
                OnboardingView()
            } else if let viewModel {
                GardenView(showArchive: $showArchive, showSettings: $showSettings)
                    .environment(viewModel)
            } else {
                Color.clear
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            if appState.hasCompletedOnboarding, viewModel == nil {
                let model = GardenViewModel(modelContext: modelContext)
                model.fetchEntries()
                viewModel = model
            }
        }
        .onChange(of: appState.hasCompletedOnboarding) { _, completed in
            if completed, viewModel == nil {
                let model = GardenViewModel(modelContext: modelContext)
                model.fetchEntries()
                viewModel = model
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                notificationService.recordActivity()
                notificationService.updateFrequencyIfNeeded()
                checkMonthTransition()
            }
        }
        .sheet(isPresented: $showArchive) {
            NavigationStack {
                ArchiveView()
            }
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                SettingsView()
            }
        }
        .overlay(alignment: .bottom) {
            if showMonthTransitionToast {
                toastView
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation(DesignConstants.Animation.standard) {
                                showMonthTransitionToast = false
                            }
                        }
                    }
            }
        }
    }

    // MARK: - Month Transition

    private func checkMonthTransition() {
        let calendar = Calendar.current
        let now = Date()
        let currentYear = calendar.component(.year, from: now)
        let currentMonth = calendar.component(.month, from: now)

        let lastYear = appState.lastActiveYear
        let lastMonth = appState.lastActiveMonth

        guard lastYear > 0,
            lastYear != currentYear || lastMonth != currentMonth
        else {
            appState.lastActiveYear = currentYear
            appState.lastActiveMonth = currentMonth
            return
        }

        let snapshotService = SnapshotService()
        let previousEntries = fetchEntries(year: lastYear, month: lastMonth)

        if snapshotService.performMonthTransition(
            modelContext: modelContext,
            previousYear: lastYear,
            previousMonth: lastMonth,
            entries: previousEntries
        ) {
            withAnimation(DesignConstants.Animation.standard) {
                showMonthTransitionToast = true
            }
        }

        appState.lastActiveYear = currentYear
        appState.lastActiveMonth = currentMonth
        viewModel?.fetchEntries()
    }

    private func fetchEntries(year: Int, month: Int) -> [MoodEntry] {
        let calendar = Calendar.current
        guard let monthStart = calendar.date(from: DateComponents(year: year, month: month)),
            let nextMonthStart = calendar.date(byAdding: .month, value: 1, to: monthStart)
        else { return [] }

        let descriptor = FetchDescriptor<MoodEntry>(
            predicate: #Predicate { $0.date >= monthStart && $0.date < nextMonthStart },
            sortBy: [SortDescriptor(\.date)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    // MARK: - Toast

    private var toastView: some View {
        Text("Last month's garden has been saved.")
            .font(DesignConstants.Typography.caption)
            .foregroundStyle(DesignConstants.Colors.textSubdued)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(.ultraThinMaterial)
            .clipShape(Capsule())
            .padding(.bottom, 40)
    }
}

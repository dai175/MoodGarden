import SwiftData
import SwiftUI

struct RootView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: GardenViewModel?
    @State private var showArchive = false
    @State private var showSettings = false

    var body: some View {
        Group {
            if let viewModel {
                GardenView(showArchive: $showArchive, showSettings: $showSettings)
                    .environment(viewModel)
            } else {
                Color.clear
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            if viewModel == nil {
                let model = GardenViewModel(modelContext: modelContext)
                model.fetchEntries()
                viewModel = model
            }
        }
        .sheet(isPresented: $showArchive) {
            archivePlaceholder
        }
        .sheet(isPresented: $showSettings) {
            settingsPlaceholder
        }
    }

    private var archivePlaceholder: some View {
        ZStack {
            DesignConstants.Colors.backgroundPrimary.ignoresSafeArea()
            Text("Archive")
                .font(DesignConstants.Typography.monthTitle)
                .foregroundStyle(
                    DesignConstants.Colors.textPrimary.opacity(DesignConstants.Colors.textOpacity)
                )
        }
        .presentationDetents([.medium])
    }

    private var settingsPlaceholder: some View {
        ZStack {
            DesignConstants.Colors.backgroundPrimary.ignoresSafeArea()
            Text("Settings")
                .font(DesignConstants.Typography.monthTitle)
                .foregroundStyle(
                    DesignConstants.Colors.textPrimary.opacity(DesignConstants.Colors.textOpacity)
                )
        }
        .presentationDetents([.medium])
    }
}

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
            placeholderSheet(title: "Archive")
        }
        .sheet(isPresented: $showSettings) {
            placeholderSheet(title: "Settings")
        }
    }

    private func placeholderSheet(title: String) -> some View {
        ZStack {
            DesignConstants.Colors.backgroundPrimary.ignoresSafeArea()
            Text(title)
                .font(DesignConstants.Typography.monthTitle)
                .foregroundStyle(DesignConstants.Colors.textSubdued)
        }
        .presentationDetents([.medium])
    }
}

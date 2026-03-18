import SwiftUI

struct SettingsView: View {
    @Environment(NotificationService.self) private var notificationService
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: SettingsViewModel?
    @State private var showResetConfirmation = false

    var body: some View {
        Group {
            if let viewModel {
                settingsForm(viewModel: viewModel)
            } else {
                Color.clear
            }
        }
        .onAppear {
            if viewModel == nil {
                viewModel = SettingsViewModel(
                    notificationService: notificationService,
                    modelContext: modelContext
                )
            }
        }
    }

    @ViewBuilder
    private func settingsForm(viewModel: SettingsViewModel) -> some View {
        @Bindable var bindableVM = viewModel
        Form {
            Section("Notifications") {
                Toggle("Daily reminder", isOn: $bindableVM.notificationEnabled)
                if viewModel.notificationEnabled {
                    DatePicker(
                        "Reminder time",
                        selection: $bindableVM.notificationTime,
                        displayedComponents: .hourAndMinute
                    )
                }
            }

            Section("About") {
                LabeledContent("Version", value: viewModel.appVersion)
            }

            Section {
                Button(role: .destructive) {
                    showResetConfirmation = true
                } label: {
                    Text("Reset All Data")
                }
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
            }
        }
        .confirmationDialog(
            "Reset all data?",
            isPresented: $showResetConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reset", role: .destructive) {
                viewModel.resetAllData()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will delete all mood entries and garden archives. This cannot be undone.")
        }
    }
}

import SwiftUI

struct MoodSelectorView: View {
    @Environment(GardenViewModel.self) private var viewModel
    @Environment(AppState.self) private var appState
    @Binding var isExpanded: Bool
    @State private var showUndo = false
    @State private var undoUsedThisSession = false
    private let handleOpacity = 0.6

    var body: some View {
        ZStack {
            if !viewModel.hasTodayEntry && !isExpanded {
                handleView
                    .transition(.opacity)
            } else if !viewModel.hasTodayEntry && isExpanded {
                expandedRow
                    .transition(.opacity)
            } else if viewModel.hasTodayEntry && showUndo {
                undoView
                    .transition(.opacity)
            }
        }
        .animation(DesignConstants.Animation.standard, value: isExpanded)
        .animation(DesignConstants.Animation.standard, value: showUndo)
        .task(id: showUndo) {
            guard showUndo else { return }
            try? await Task.sleep(for: .seconds(3))
            guard !Task.isCancelled else { return }
            showUndo = false
        }
    }

    // MARK: - Collapsed State

    private var handleView: some View {
        Button {
            isExpanded = true
        } label: {
            Capsule()
                .fill(DesignConstants.Colors.accent.opacity(handleOpacity))
                .frame(width: 48, height: 6)
                .frame(width: 80, height: 44)
                .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Record mood")
    }

    // MARK: - Expanded Row

    private var expandedRow: some View {
        HStack(spacing: 16) {
            ForEach(MoodType.allCases, id: \.self) { mood in
                Button {
                    selectMood(mood)
                } label: {
                    MoodIcon(mood: mood)
                        .frame(minWidth: 44, minHeight: 44)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(mood.rawValue)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(DesignConstants.Colors.backgroundSecondary.opacity(0.6))
        )
    }

    // MARK: - Undo

    private var undoView: some View {
        Button {
            performUndo()
        } label: {
            Text("Undo")
                .font(DesignConstants.Typography.caption)
                .foregroundStyle(DesignConstants.Colors.textSubdued)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(
                            DesignConstants.Colors.backgroundSecondary.opacity(0.8))
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Undo mood recording")
    }

    // MARK: - Actions

    private func selectMood(_ mood: MoodType) {
        viewModel.recordMood(mood)
        appState.totalRecordCount += 1
        isExpanded = false

        if !undoUsedThisSession {
            showUndo = true
        }
    }

    private func performUndo() {
        viewModel.undoLastMood()
        appState.totalRecordCount = max(0, appState.totalRecordCount - 1)
        undoUsedThisSession = true
        showUndo = false
    }
}

import SwiftUI

struct MoodSelectorView: View {
    @Environment(GardenViewModel.self) private var viewModel
    @State private var isExpanded = false

    var body: some View {
        Group {
            if isExpanded {
                expandedView
                    .transition(.opacity.combined(with: .scale))
            } else {
                addButton
                    .transition(.opacity.combined(with: .scale))
            }
        }
        .animation(DesignConstants.Animation.standard, value: isExpanded)
    }

    private var addButton: some View {
        Button {
            isExpanded = true
        } label: {
            Image(systemName: "plus")
                .font(.system(size: 20, weight: .medium))
                .foregroundStyle(DesignConstants.Colors.accent)
                .frame(width: 44, height: 44)
                .background(
                    Circle()
                        .fill(DesignConstants.Colors.accent.opacity(DesignConstants.Layout.glassOpacity))
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Record mood")
    }

    private var expandedView: some View {
        HStack(spacing: 12) {
            ForEach(MoodType.allCases, id: \.self) { mood in
                Button {
                    selectMood(mood)
                } label: {
                    MoodIcon(mood: mood)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(DesignConstants.Colors.backgroundSecondary.opacity(0.8))
        )
    }

    private func selectMood(_ mood: MoodType) {
        viewModel.recordMood(mood)
        isExpanded = false
    }
}

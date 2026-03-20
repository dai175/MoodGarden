import SwiftUI

struct MoodSelectorView: View {
    @Environment(GardenViewModel.self) private var viewModel
    @Environment(AppState.self) private var appState
    @State private var isExpanded = false
    @State private var showUndo = false
    @State private var lastRecordedMood: MoodType?
    @State private var undoUsedThisSession = false
    @State private var pulseScale: CGFloat = 1.0

    private let arcRadius: CGFloat = 100
    private let arcStartAngle: Double = -90
    private let arcEndAngle: Double = 90

    var body: some View {
        ZStack {
            if showUndo {
                undoView
                    .transition(.opacity)
            } else if isExpanded {
                arcView
                    .transition(.opacity)
            } else {
                glowingDot
                    .transition(.opacity)
            }
        }
        .animation(DesignConstants.Animation.standard, value: isExpanded)
        .animation(DesignConstants.Animation.standard, value: showUndo)
    }

    // MARK: - Collapsed State

    private var glowingDot: some View {
        Button {
            isExpanded = true
        } label: {
            Circle()
                .fill(DesignConstants.Colors.accent)
                .frame(width: 12, height: 12)
                .scaleEffect(pulseScale)
                .opacity(0.8)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Record mood")
        .onAppear {
            withAnimation(
                .easeInOut(duration: 2.0).repeatForever(autoreverses: true)
            ) {
                pulseScale = 1.3
            }
        }
    }

    // MARK: - Arc Layout

    private var arcView: some View {
        ZStack {
            // Dismiss area
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    isExpanded = false
                }

            // Arc of mood icons
            ForEach(Array(MoodType.allCases.enumerated()), id: \.element) { index, mood in
                let position = arcPosition(for: index, total: MoodType.allCases.count)
                Button {
                    selectMood(mood)
                } label: {
                    MoodIcon(mood: mood)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(mood.rawValue)
                .offset(x: position.x, y: position.y)
            }
        }
        .frame(width: arcRadius * 2 + 60, height: arcRadius + 60)
    }

    private func arcPosition(for index: Int, total: Int) -> CGPoint {
        let step = (arcEndAngle - arcStartAngle) / Double(total - 1)
        let angleDegrees = arcStartAngle + step * Double(index)
        let angleRadians = angleDegrees * .pi / 180
        let x = cos(angleRadians) * arcRadius
        let y = sin(angleRadians) * arcRadius
        return CGPoint(x: x, y: y)
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
        lastRecordedMood = mood
        isExpanded = false

        if !undoUsedThisSession {
            showUndo = true
            Task {
                try? await Task.sleep(for: .seconds(3))
                showUndo = false
            }
        }
    }

    private func performUndo() {
        viewModel.undoLastMood()
        appState.totalRecordCount = max(0, appState.totalRecordCount - 1)
        undoUsedThisSession = true
        showUndo = false
        lastRecordedMood = nil
    }
}

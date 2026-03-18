import SwiftUI

struct OnboardingView: View {
    @Environment(AppState.self) private var appState
    @Environment(NotificationService.self) private var notificationService

    @State private var currentPage = 0
    @State private var selectedHour = 21
    @State private var selectedMinute = 0

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    DesignConstants.Colors.backgroundPrimary,
                    DesignConstants.Colors.backgroundSecondary,
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            TabView(selection: $currentPage) {
                welcomePage.tag(0)
                philosophyPage.tag(1)
                notificationPage.tag(2)
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
        .preferredColorScheme(.dark)
    }

    private var welcomePage: some View {
        VStack(spacing: 32) {
            Spacer()
            moodIconsCircle
            Text("Your garden grows\nwith your emotions.")
                .font(DesignConstants.Typography.monthTitle)
                .foregroundStyle(DesignConstants.Colors.textSubdued)
                .multilineTextAlignment(.center)
            Spacer()
            pageIndicatorHint
        }
        .padding(32)
    }

    private var philosophyPage: some View {
        VStack(spacing: 32) {
            Spacer()
            Image(systemName: "leaf.fill")
                .font(.system(size: 48))
                .foregroundStyle(DesignConstants.Colors.accent)
            Text("Every mood is welcome here.\nThere is no good or bad weather.")
                .font(DesignConstants.Typography.bodyText)
                .foregroundStyle(DesignConstants.Colors.textSubdued)
                .multilineTextAlignment(.center)
            Spacer()
            pageIndicatorHint
        }
        .padding(32)
    }

    private var notificationPage: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("Record once a day.\nThat's all.")
                .font(DesignConstants.Typography.monthTitle)
                .foregroundStyle(DesignConstants.Colors.textSubdued)
                .multilineTextAlignment(.center)

            Text("Reminder time")
                .font(DesignConstants.Typography.caption)
                .foregroundStyle(DesignConstants.Colors.textSubdued)

            timePicker

            Spacer()

            Button {
                Task { await completeOnboarding() }
            } label: {
                Text("Begin")
                    .font(DesignConstants.Typography.bodyText)
                    .foregroundStyle(DesignConstants.Colors.backgroundPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(DesignConstants.Colors.accent)
                    .clipShape(Capsule())
            }
        }
        .padding(32)
    }

    private var moodIconsCircle: some View {
        HStack(spacing: 16) {
            ForEach(MoodType.allCases, id: \.self) { mood in
                MoodIcon(mood: mood, size: 28)
            }
        }
    }

    private var timePicker: some View {
        HStack(spacing: 4) {
            Picker("Hour", selection: $selectedHour) {
                ForEach(0..<24, id: \.self) { hour in
                    Text(String(format: "%02d", hour)).tag(hour)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 60, height: 100)
            .clipped()

            Text(":")
                .font(DesignConstants.Typography.monthTitle)
                .foregroundStyle(DesignConstants.Colors.textSubdued)

            Picker("Minute", selection: $selectedMinute) {
                ForEach(Array(stride(from: 0, to: 60, by: 5)), id: \.self) { minute in
                    Text(String(format: "%02d", minute)).tag(minute)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 60, height: 100)
            .clipped()
        }
    }

    private var pageIndicatorHint: some View {
        Text("Swipe to continue")
            .font(DesignConstants.Typography.caption)
            .foregroundStyle(DesignConstants.Colors.textSubdued.opacity(0.5))
    }

    private func completeOnboarding() async {
        let granted = await notificationService.requestPermission()
        if granted {
            await notificationService.updateTime(
                hour: selectedHour, minute: selectedMinute
            )
        }
        withAnimation(DesignConstants.Animation.standard) {
            appState.hasCompletedOnboarding = true
        }
    }
}

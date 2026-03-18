import SwiftUI

struct ArchiveView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel: ArchiveViewModel?
    @State private var selectedMonth: ArchiveViewModel.MonthInfo?

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16),
    ]

    var body: some View {
        Group {
            if let viewModel {
                archiveContent(viewModel: viewModel)
            } else {
                Color.clear
            }
        }
        .onAppear {
            if viewModel == nil {
                let newViewModel = ArchiveViewModel(modelContext: modelContext)
                newViewModel.fetchData()
                viewModel = newViewModel
            }
        }
    }

    private func archiveContent(viewModel: ArchiveViewModel) -> some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(viewModel.months) { monthInfo in
                    monthCard(monthInfo, viewModel: viewModel)
                }
            }
            .padding()
        }
        .navigationTitle("Archive")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedMonth) { monthInfo in
            ArchiveDetailView(
                year: monthInfo.year,
                month: monthInfo.month,
                entries: viewModel.entriesForMonth(
                    year: monthInfo.year, month: monthInfo.month
                )
            )
        }
    }

    private func monthCard(
        _ monthInfo: ArchiveViewModel.MonthInfo,
        viewModel: ArchiveViewModel
    ) -> some View {
        Button {
            selectedMonth = monthInfo
        } label: {
            VStack(spacing: 8) {
                thumbnailView(for: monthInfo)
                    .frame(height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: DesignConstants.Layout.cornerRadius))

                Text(monthInfo.displayName)
                    .font(DesignConstants.Typography.caption)
                    .foregroundStyle(DesignConstants.Colors.textSubdued)

                if monthInfo.isCurrent {
                    Text("In progress")
                        .font(.caption2)
                        .foregroundStyle(DesignConstants.Colors.accent)
                }
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func thumbnailView(for monthInfo: ArchiveViewModel.MonthInfo) -> some View {
        if let imageData = monthInfo.garden?.snapshotImage,
            let uiImage = UIImage(data: imageData)
        {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
        } else {
            RoundedRectangle(cornerRadius: DesignConstants.Layout.cornerRadius)
                .fill(DesignConstants.Colors.backgroundSecondary)
                .overlay {
                    if monthInfo.isCurrent {
                        Image(systemName: "leaf.fill")
                            .foregroundStyle(DesignConstants.Colors.accent.opacity(0.3))
                    }
                }
        }
    }
}

// Temporary placeholder - will be replaced by Task 6
struct ArchiveDetailView: View {
    let year: Int
    let month: Int
    let entries: [MoodEntry]
    var body: some View { EmptyView() }
}

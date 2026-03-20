import Foundation
import SpriteKit
import SwiftUI

struct ArchiveDetailView: View {
    let year: Int
    let month: Int
    let entries: [MoodEntry]

    @State private var detailScene = GardenScene()

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

            VStack {
                Spacer()
                SpriteView(scene: detailScene)
                    .aspectRatio(
                        CGFloat(DesignConstants.Layout.gridColumns)
                            / CGFloat(DesignConstants.Layout.gridRows),
                        contentMode: .fit
                    )
                    .clipShape(
                        RoundedRectangle(cornerRadius: DesignConstants.Layout.cornerRadius)
                    )
                Spacer()
            }
            .padding()
        }
        .navigationTitle(displayName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            let season = Season.from(month: month)
            let state = AtmosphereEngine.analyze(entries: entries, season: season)
            detailScene.configure(with: state)
            detailScene.configureSeason(month: month)
        }
    }

    private var displayName: String {
        let components = DateComponents(year: year, month: month)
        guard let date = Calendar.current.date(from: components) else { return "" }
        return DesignConstants.Formatters.monthYear.string(from: date)
    }
}

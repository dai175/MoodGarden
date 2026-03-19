import Foundation

struct AtmosphereState: Equatable {
    let moodRatios: [MoodType: Float]
    let dominantMood: MoodType?
    let hueShift: Float
    let elementManifest: [ElementSpec]

    var totalEstimatedNodes: Int {
        elementManifest.reduce(0) { $0 + $1.estimatedNodes }
    }

    static let empty = AtmosphereState(
        moodRatios: [:],
        dominantMood: nil,
        hueShift: 0,
        elementManifest: []
    )
}

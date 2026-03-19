enum MoodPalette {
    private static let maxHueShift: Float = 0.15

    struct Result: Equatable {
        let hueShift: Float  // -maxHueShift to maxHueShift. Positive = warm, negative = cool
    }

    /// Hue direction per mood. All are equally valid aesthetic directions.
    private static let hueDirections: [MoodType: Float] = [
        .peaceful: 0.02,  // slight warm green
        .happy: 0.12,  // warm gold
        .energetic: 0.08,  // bright green-gold
        .anxious: -0.05,  // slight cool purple
        .sad: -0.10,  // cool blue
        .angry: -0.03,  // deep green
        .tired: 0.04,  // amber
    ]

    static func analyze(moodRatios: [MoodType: Float]) -> Result {
        guard !moodRatios.isEmpty else {
            return Result(hueShift: 0)
        }
        var shift: Float = 0
        for (mood, ratio) in moodRatios {
            shift += (hueDirections[mood] ?? 0) * ratio
        }
        let capped = shift.clamped(to: -maxHueShift...maxHueShift)
        return Result(hueShift: capped)
    }
}

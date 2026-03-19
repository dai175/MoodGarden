import CoreGraphics

enum PlacementZone: CaseIterable {
    case sky, hilltop, waterside, foreground, anywhere

    /// Zone bounds as ratios of sceneSize (origin at center).
    /// Preliminary — will be tuned when background images are finalized.
    var boundsRatio: CGRect {
        switch self {
        case .sky: return CGRect(x: -0.5, y: 0.15, width: 1.0, height: 0.35)
        case .hilltop: return CGRect(x: -0.5, y: -0.05, width: 0.5, height: 0.2)
        case .waterside: return CGRect(x: 0.0, y: -0.15, width: 0.5, height: 0.2)
        case .foreground: return CGRect(x: -0.5, y: -0.5, width: 1.0, height: 0.35)
        case .anywhere: return CGRect(x: -0.5, y: -0.5, width: 1.0, height: 1.0)
        }
    }

    func absoluteBounds(sceneSize: CGSize) -> CGRect {
        CGRect(
            x: boundsRatio.origin.x * sceneSize.width,
            y: boundsRatio.origin.y * sceneSize.height,
            width: boundsRatio.width * sceneSize.width,
            height: boundsRatio.height * sceneSize.height
        )
    }
}

import CoreGraphics

/// Computes pseudo-3D depth effects based on Y position within the scene.
/// Higher Y (top of scene) = farther away = smaller/fainter.
/// Lower Y (bottom of scene) = closer = larger/brighter.
enum DepthScale {
    /// Scale range: 0.65 (far/top) to 1.15 (near/bottom).
    static let scaleRange: ClosedRange<CGFloat> = 0.65...1.15

    /// Alpha range: 0.75 (far/top) to 1.0 (near/bottom).
    static let alphaRange: ClosedRange<CGFloat> = 0.75...1.0

    /// Z-offset range: 0 (far/top) to 5 (near/bottom).
    static let zOffsetRange: ClosedRange<CGFloat> = 0...5

    /// Normalized depth factor from Y position (0 = top/far, 1 = bottom/near).
    static func depthFactor(y: CGFloat, sceneHeight: CGFloat) -> CGFloat {
        guard sceneHeight > 0 else { return 0.5 }
        // Scene anchor is center, so y ranges from -height/2 (bottom) to +height/2 (top).
        // Map: top (+height/2) → 0, bottom (-height/2) → 1
        let normalized = 1.0 - (y + sceneHeight / 2) / sceneHeight
        return normalized.clamped(to: 0...1)
    }

    static func scale(y: CGFloat, sceneHeight: CGFloat) -> CGFloat {
        let t = depthFactor(y: y, sceneHeight: sceneHeight)
        return lerp(from: scaleRange.lowerBound, to: scaleRange.upperBound, t: t)
    }

    static func alpha(y: CGFloat, sceneHeight: CGFloat) -> CGFloat {
        let t = depthFactor(y: y, sceneHeight: sceneHeight)
        return lerp(from: alphaRange.lowerBound, to: alphaRange.upperBound, t: t)
    }

    static func zOffset(y: CGFloat, sceneHeight: CGFloat) -> CGFloat {
        let t = depthFactor(y: y, sceneHeight: sceneHeight)
        return lerp(from: zOffsetRange.lowerBound, to: zOffsetRange.upperBound, t: t)
    }

    private static func lerp(from a: CGFloat, to b: CGFloat, t: CGFloat) -> CGFloat {
        a + (b - a) * t
    }
}

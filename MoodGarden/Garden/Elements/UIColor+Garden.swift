import UIKit

extension UIColor {
    func withHueOffset(_ offset: CGFloat, brightnessMultiplier: CGFloat = 1.0) -> UIColor {
        var hue: CGFloat = 0
        var sat: CGFloat = 0
        var bri: CGFloat = 0
        var alp: CGFloat = 0
        guard getHue(&hue, saturation: &sat, brightness: &bri, alpha: &alp) else {
            return self
        }
        let adjustedHue = ((hue + offset).truncatingRemainder(dividingBy: 1.0) + 1.0)
            .truncatingRemainder(dividingBy: 1.0)
        return UIColor(
            hue: adjustedHue,
            saturation: sat,
            brightness: min(bri * brightnessMultiplier, 1.0),
            alpha: alp
        )
    }
}

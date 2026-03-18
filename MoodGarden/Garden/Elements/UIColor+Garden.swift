import UIKit

extension UIColor {
    func withHueOffset(_ offset: CGFloat, brightnessMultiplier: CGFloat = 1.0) -> UIColor {
        var hue: CGFloat = 0
        var sat: CGFloat = 0
        var bri: CGFloat = 0
        var alp: CGFloat = 0
        getHue(&hue, saturation: &sat, brightness: &bri, alpha: &alp)
        return UIColor(
            hue: (hue + offset).truncatingRemainder(dividingBy: 1.0),
            saturation: sat,
            brightness: bri * brightnessMultiplier,
            alpha: alp
        )
    }
}

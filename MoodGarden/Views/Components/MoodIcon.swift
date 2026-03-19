import SwiftUI

struct MoodIcon: View {
    let mood: MoodType
    var size: CGFloat = 36

    var body: some View {
        Image(systemName: mood.iconName)
            .font(.system(size: size * 0.5))
            .foregroundStyle(mood.color)
            .frame(width: size, height: size)
            .accessibilityLabel(mood.displayName)
    }
}

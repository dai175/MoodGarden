import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            Color(red: 0.039, green: 0.102, blue: 0.071)
                .ignoresSafeArea()
            Text("MoodGarden")
                .font(.title)
                .foregroundStyle(Color(red: 0.910, green: 0.894, blue: 0.863).opacity(0.8))
        }
        .preferredColorScheme(.dark)
    }
}

#Preview {
    ContentView()
}

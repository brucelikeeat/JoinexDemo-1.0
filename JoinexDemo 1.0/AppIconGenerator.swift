import SwiftUI

struct AppIconGenerator: View {
    var body: some View {
        ZStack {
            // Background - iOS app icons need a solid background
            Color.white
                .ignoresSafeArea()
            
            // Your logo centered
            Image("logo1")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 800, height: 800) // Leave padding for iOS
                .background(Color.white)
        }
        .frame(width: 1024, height: 1024)
    }
}

#Preview {
    AppIconGenerator()
} 
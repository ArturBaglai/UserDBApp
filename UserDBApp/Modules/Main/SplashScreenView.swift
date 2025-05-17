import SwiftUI

struct SplashScreenView: View {
    
    var body: some View {
        ZStack {
            Color.primaryYellow
            VStack {
                Image("Logo")
                    .resizable()
                    .frame(width: 160, height: 106)
            }
        }
    }
}
#Preview {
    SplashScreenView()
}

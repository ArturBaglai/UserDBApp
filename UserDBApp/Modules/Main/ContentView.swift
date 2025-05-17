import SwiftUI

public struct ContentView: View {
    @State private var isActive: Bool = false
    let userService: UserServiсe
    let mainViewModel: MainViewModel

    init(userService: UserServiсe, mainViewModel: MainViewModel) {
        self.userService = userService
        self.mainViewModel = mainViewModel
    }

    public var body: some View {
        Group {
            if isActive {
                MainView()
                    .environmentObject(mainViewModel)
            } else {
                SplashScreenView()
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    isActive = true
                }
            }
        }
    }
}

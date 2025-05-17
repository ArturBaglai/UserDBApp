import SwiftUI

struct NoInternetConnectionView: View {
    
    @EnvironmentObject var mainViewModel: MainViewModel
    @ObservedObject private var networkMonitor = NetworkMonitor.shared

    var body: some View {
        VStack {
            Image("noInternet")
                .foregroundColor(.red)
                .font(.system(size: 48))
            
            Text("No internet connection.")
                .font(.system(size: 20))
            
            Button(action: {
               
            }) {
                Text("Try again")
                    .frame(width: 140, height: 48)
                    .background(Color.gray.opacity(0.5))
                    .foregroundColor(.white)
                    .cornerRadius(24)
            }
        }
        .onChange(of: networkMonitor.isConnected) { isConnected in
            if isConnected {
                print("Intenet connection restored, navigate to MainView()")
            }
        }
    }
}
#Preview {
    NoInternetConnectionView()
}

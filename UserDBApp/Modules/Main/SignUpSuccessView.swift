import SwiftUI

public struct SignUpSuccessView: View {
    
    public var body: some View {
        NavigationView {
            VStack {
                Image("SignUpSuccess")
                Text ("User successfully registered")
                NavigationLink(destination: MainView())
                {
                    Text("Got it")
                        .frame(maxWidth: 140)
                        .padding()
                        .background(.yellow)
                        .foregroundColor(.black)
                        .cornerRadius(100)
                }
            }
        }
    }
}



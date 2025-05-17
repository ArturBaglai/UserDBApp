import SwiftUI

struct HeaderView: View {

    var body: some View {
        VStack {
            Text("Working with POST request")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.primaryYellow)
        }
        .frame(height: 60)
    }
}


import SwiftUI

struct UsersEmptyView: View {
    
    var body: some View {
        NavigationView {
            VStack {
               HeaderView()
                VStack(spacing: 20) {
                    Image("noUsers")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 150, height: 150)
                        .foregroundColor(Color.blue.opacity(0.5))
                }
                Text("There are no users yet")
                    .font(.body)
                    .foregroundColor(.black)
            }
            Spacer()
        }
    }
}
#Preview {
    UsersEmptyView()
}

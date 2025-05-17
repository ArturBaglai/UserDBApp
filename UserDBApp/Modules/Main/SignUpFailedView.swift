import SwiftUI

public struct SignUpFailedView: View {
    
    @EnvironmentObject private var registrationViewModel: RegistrationViewModel
    @Environment(\.dismiss) private var dismiss

    public var body: some View {
        VStack(spacing: 24) {
            Image("SignUpFailed")
            
            if let errorMessage = registrationViewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }
            
            Button {
                registrationViewModel.resetForm()
                dismiss() 
            } label: {
                Text("Try again")
                    .frame(maxWidth: 140)
                    .padding()
                    .background(Color.yellow)
                    .foregroundColor(.black)
                    .cornerRadius(100)
            }
        }
        .padding()
        .background(Color.white)
    }
}

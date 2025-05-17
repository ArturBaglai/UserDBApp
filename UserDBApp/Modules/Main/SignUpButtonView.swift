import SwiftUI

struct SignUpButtonView: View {
    
    @EnvironmentObject private var registrationViewModel: RegistrationViewModel
    var autorisationServise: AuthorisationService
    
    var body: some View {
        Button(action: {
            Task {
                await registrationViewModel.handleSignUp()
            }
        }) {
            Text("Sign up")
                .frame(width: 140, height: 48)
                .background(Color.gray.opacity(0.5))
                .foregroundColor(.white)
                .background(registrationViewModel.isFormCompletelyEmpty ? Color.buttonDisabled : Color.primaryYellow)
                .cornerRadius(24)
        }
        .disabled(registrationViewModel.isFormCompletelyEmpty)
        if registrationViewModel.successRegistration == true {
            SignUpSuccessView()
        }
    }
}


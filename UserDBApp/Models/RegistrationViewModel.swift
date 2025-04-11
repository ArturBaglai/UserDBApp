import Foundation
import SwiftUI
import PhotosUI

@MainActor
class RegistrationViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var phone: String = ""
    @Published var position: String = ""
    @Published var positionId: Int = 1
    @Published var photo: Data = Data() 
    @Published var validationErrors: [String: [String]]?
    @Published var successRegistration: Bool = false
    @Published var errorMessage: String?

    private var registrationService: RegistrationService

    init(registrationService: RegistrationService) {
        self.registrationService = registrationService
    }

    func handleSignUp() async {
        let user = User(
            id: 0,
            name: name,
            email: email,
            phone: phone,
            position: position,
            positionId: 1,
            photoUrl: nil
        )

        let request = RegistrationRequest(user: user)
        let result = await registrationService.register(request: request)

        DispatchQueue.main.async {
            switch result {
            case .success(let userId):
                self.successRegistration = true
                print("Registration successful: User ID = \(userId)")
            case .failure(let error):
                self.errorMessage = "Registration failed: \(error.localizedDescription)"
            }
        }
    }
}

struct TextFieldView: View {
    let label: String
    @Binding var text: String
    @Binding var state: TextFieldState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            TextField(label, text: $text)
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 5)
                    .stroke(strokeColor(), lineWidth: 1)
                )
                .onChange(of: text) { newValue, _ in
                    if case .success = state {} else {
                        state = .default
                    }
                    if case .focused = state {
                        state = .focused
                    }
                }
            if case .error(let message) = state {
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.red)
            }
        }
    }
    
private func strokeColor() -> Color {
        switch state {
        case .default:
            return .gray
        case .error:
            return .red
        case .success:
            return .gray
        case .focused:
            return .blue
        }
    }
}

enum TextFieldState {
    case `default`
    case success
    case error(message: String)
    case focused
}

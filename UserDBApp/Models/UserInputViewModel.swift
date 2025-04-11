import SwiftUI

class UserInputViewModel: ObservableObject {
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var phone: String = ""
    @Published var selectedOption: String = ""
    @Published var positionId: Int = 0
    @Published var validationErrors: [String: [String]] = [:]
    
    func validationFields() -> Bool {
        validationErrors = [:]
        
        if name.isEmpty {
            validationErrors["name"] = ["Name is required"]
        }
        if email.isEmpty {
            validationErrors["email"] = ["Invalid email adress"]
        }
        if phone.isEmpty {
            validationErrors["phone"] = ["Phone number is required"]
        }
        return validationErrors.isEmpty
    }
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return NSPredicate(format: "SELf MATCHES %@", emailRegex).evaluate(with: email)
    }
}

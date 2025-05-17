import SwiftUI

@MainActor
class RegistrationViewModel: ObservableObject {
    
    @EnvironmentObject var mainViewModel: MainViewModel
    @Published var name: String = ""
    @Published var email: String = ""
    @Published var phone: String = ""
    @Published var position: String = ""
    @Published var positionId: Int = 1
    @Published var photoData: Data = Data()
    @Published var validationErrors: [String: [String]] = [:]
    @Published var successRegistration: Bool? = nil
    @Published var errorMessage: String?
    @Published var didSubmit: Bool = false
    @Published var registeredUser: User?
    
    var isFormCompletelyEmpty: Bool {
        name.isEmpty &&
        email.isEmpty &&
        phone.isEmpty &&
        photoData.isEmpty
    }
    
    private var registrationService: RegistrationService
    let userInputViewModel: UserInputViewModel

    init(registrationService: RegistrationService, userInputViewModel: UserInputViewModel) {
        self.registrationService = registrationService
        self.userInputViewModel = userInputViewModel
    }

    func handleSignUp() async {
        self.didSubmit = true
        let isValid = userInputViewModel.validationFields()
        self.validationErrors = userInputViewModel.validationErrors
        
        let user = User(
            id: 0,
            name: name,
            email: email,
            phone: phone,
            position: position,
            positionId: positionId,
            photoUrl: nil
        )

        let request = RegistrationRequest(user: user, photo: photoData)
        let result = await registrationService.register(request: request)
        
        switch result {
        case .success:
            mainViewModel.users.insert(user, at: 0)
            self.successRegistration = true
            
        case .failure(let error):
            self.successRegistration = false
            
            if let apiError = error as? APIError {
                switch apiError {
                case .phoneOrEmailExists:
                    self.errorMessage = apiError.message
                case .validationError(let response):
                   if let fails = response.fails {
                        self.validationErrors = fails
                   } else {
                       self.errorMessage = response.message
                   }
                case .noInthernetConnection:
                    self.errorMessage = apiError.message
                case .expiredToken:
                    self.errorMessage = apiError.message
                case .unexpectedError(code: let code, message: let message):
                    self.errorMessage = apiError.message
                case .noData:
                    self.errorMessage = apiError.message
                case .decodingError(_):
                    self.errorMessage = apiError.message
                }
            } else {
                self.errorMessage = error.localizedDescription
            }
            print(error)
        }
    }
    func resetForm() {
        name = ""
        email = ""
        phone = ""
        positionId = 0
        photoData = Data()
        validationErrors = [:]
        successRegistration = false
        errorMessage = nil
    }
}

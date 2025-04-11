import Foundation

@MainActor
class AuthorisationService: ObservableObject {
    
    @Published var token: String = ""
    @Published var errorMessage: String?
    @Published var isTokenFetched: Bool = false
    @Published var userService: UserServiсe
    
    init(userServise: UserServiсe) {
        self.userService = userServise
    }
    func userToken() async -> String {
        do {
          let response = try await userService.token(from: UserServiсe.Endpoint.token)
          self.token = response.token
          self.isTokenFetched = true
          return response.token
           } catch let error as APIError {
              self.errorMessage = error.message
              return ""
           } catch {
              self.errorMessage = "Unknown error occurred"
              return ""
        }
    }
}



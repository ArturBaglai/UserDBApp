import SwiftUI

class RegistrationService: ObservableObject {
    private var userService: UserServiсe

    init(userService: UserServiсe) {
        self.userService = userService
    }

    func register(request: RegistrationRequest) async -> Result<Void, Error> {
        do {
            let tokenResponse = try await userService.token(from: UserServiсe.Endpoint.token)
            let token = tokenResponse.token

            let response = try await userService.newUser(
                from: UserServiсe.Endpoint.users.rawValue,
                user: request.user,
                photoData: request.photo,
                token: token
            )

            if response.success {
                return .success(())
            } else {
                return .failure(NSError(domain: "RegistrationError", code: 0, userInfo: [NSLocalizedDescriptionKey: response.message]))
            }
        } catch {
            return .failure(error)
        }
    }
}

import SwiftUI

@MainActor
class PositionSelectionViewModel: ObservableObject {
    @Published var positions: [String] = []
    @Published var positionIds: [Int] = []
    @Published var positionsLoading: Bool = false
    @Published var errorMessage: String?
    @Published var validationErrors: [String: [String]]?
    
    private var apiClient: HTTPClient
    let userServise: UserServiсe
    
    init(userService: UserServiсe, apiClient: HTTPClient) {
        self.userServise = userService
        self.apiClient = apiClient
    }
    
    func loadPositions() async {
        positionsLoading = true
        do {
            let response = try await userServise.positions()

            if self.positions.isEmpty {
                self.positions = response.positions.map { $0.name }
                self.positionIds = response.positions.map { $0.id }
            }
            self.positionsLoading = false

        } catch {
            self.errorMessage = "Failed to load positions: \(error.localizedDescription)"
            self.positionsLoading = false
        }
    }

}


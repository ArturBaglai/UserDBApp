import Foundation

@MainActor
class MainViewModel: ObservableObject {
    
    @Published var users: [User]
    @Published private(set) var errorMessage: String?
    @Published private(set) var isLoading: Bool

    private var userService: UserServiсe
    private var currentPage = 1
    private var nextPage: String?
    private var previousPage: String?

    init(
        users: [User] = [],
        errorMessage: String? = nil,
        isLoading: Bool = false,
        userService: UserServiсe,
        currentPage: Int = 1,
        nextPage: String? = nil,
        previousPage: String? = nil
    ) {
        self.users = users
        self.errorMessage = errorMessage
        self.isLoading = isLoading
        self.userService = userService
        self.currentPage = currentPage
        self.nextPage = nextPage
        self.previousPage = previousPage
    }

    func loadUsers() async {
        isLoading = true
        do {
            let response = try await userService.users(page: currentPage, count: 6)

            self.users.append(contentsOf: response.users)
            self.nextPage = response.links.nextURL
            self.previousPage = response.links.prevURL
            self.isLoading = false
        } catch let error as UserServiсe.UserError {
           
            switch error {
            case let .pageError(message):
                self.errorMessage = message
            case let .validationError(error):
                self.errorMessage = error.toString()
            case .networkError:
                self.errorMessage = "Something went wrong :("
            }
            self.isLoading = false
        } catch {
            self.errorMessage = "Unknown error: \(error.localizedDescription)"
            self.isLoading = false
        }
    }

    func loadMoreUsers() async {
        guard !isLoading, nextPage != nil || !users.isEmpty else { return }
        currentPage += 1
        await loadUsers()
    }
}

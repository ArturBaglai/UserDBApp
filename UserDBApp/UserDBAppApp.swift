import SwiftUI

@main
struct UserDBApp: App {
    @StateObject private var mainViewModel: MainViewModel
    @StateObject private var registrationViewModel: RegistrationViewModel
    @StateObject private var positionSelectionViewModel: PositionSelectionViewModel
    @StateObject private var authorisationServise: AuthorisationService
    @StateObject private var userStorage: UserStorage
    @StateObject private var networkMonitor = NetworkMonitor.shared
    @StateObject private var userServiсe: UserServiсe
    @StateObject private var registrationServise: RegistrationService
    @StateObject private var userInputViewModel: UserInputViewModel

    init() {
        let httpClient = HTTPClient()
        let userService = UserServiсe(httpClient: httpClient)
        let apiClient = HTTPClient()
        let authorisationServise = AuthorisationService(userServise: userService)
        let registrationService = RegistrationService(userService: userService)
        let userStorage = UserStorage()
        let userInputViewModel = UserInputViewModel()
        
        _userServiсe = StateObject(wrappedValue: userService)
        _authorisationServise = StateObject(wrappedValue: authorisationServise)
        _mainViewModel = StateObject(wrappedValue: MainViewModel(userService: userService))
        _registrationViewModel = StateObject(wrappedValue: RegistrationViewModel(registrationService: registrationService))
        _positionSelectionViewModel = StateObject(wrappedValue: PositionSelectionViewModel(userService: userService, apiClient: httpClient))
        _userStorage = StateObject(wrappedValue: userStorage)
        _registrationServise = StateObject(wrappedValue: registrationService)
        _userInputViewModel = StateObject(wrappedValue: userInputViewModel)
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                if networkMonitor.isConnected {
                    TabView {
                        Tab("Users", image: "users") {
                            MainView()
                                .environmentObject(mainViewModel)
                        }
                        Tab("Sign up", image: "AddUser") {
                            RegistrationView(registrationViewModel: registrationViewModel, autorisationServise: authorisationServise, userStorage: userStorage)
                                .environmentObject(registrationViewModel)
                                .environmentObject(positionSelectionViewModel)
                                .environmentObject(userInputViewModel)
                        }
                    }
                } else {
                    NoInternetConnectionView()
                        .environmentObject(mainViewModel)
                }
            }
        }
    }
}

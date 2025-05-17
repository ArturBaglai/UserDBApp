import SwiftUI

struct RootView: View {
    
    @EnvironmentObject var mainViewModel: MainViewModel
    @EnvironmentObject var registrationViewModel: RegistrationViewModel
    @EnvironmentObject var positionSelectionViewModel: PositionSelectionViewModel
    @EnvironmentObject var authorisationService: AuthorisationService
    @EnvironmentObject var userStorage: UserStorage
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @EnvironmentObject var userInputViewModel: UserInputViewModel

    @State private var isSplashActive = true
    @State private var selectedTab: UserDatabaseApp.Tab = .users

    var body: some View {
        Group {
            if isSplashActive {
                SplashScreenView()
            } else {
                if networkMonitor.isConnected {
                    TabView(selection: $selectedTab) {
                        MainView()
                            .environmentObject(mainViewModel)
                            .tabItem {
                                HStack {
                                    if $selectedTab.wrappedValue == .users {
                                        Label("Users", image: "users")
                                    } else {
                                        Label("Users", image: "usersDeisabled")
                                    }
                                }
                            }
                            .tag(UserDatabaseApp.Tab.users)

                        RegistrationView(
                            registrationViewModel: registrationViewModel,
                            autorisationServise: authorisationService,
                            userStorage: userStorage,
                            selectedTab: $selectedTab
                        )
                        .environmentObject(registrationViewModel)
                        .environmentObject(positionSelectionViewModel)
                        .environmentObject(userInputViewModel)
                        .tabItem {
                            HStack {
                                if $selectedTab.wrappedValue == .register {
                                    Label("Sign up", image: "signUpEnabled")
                                } else {
                                    Label("Sign up", image: "signUpDisabled")
                                }
                            }
                        }
                        .tag(UserDatabaseApp.Tab.register)
                        .onChange(of: selectedTab) { tab in
                            if tab == .register {
                                registrationViewModel.resetForm()
                            }
                        }
                    }
                } else {
                    NoInternetConnectionView()
                        .environmentObject(mainViewModel)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    isSplashActive = false
                }
            }
        }
    }
}

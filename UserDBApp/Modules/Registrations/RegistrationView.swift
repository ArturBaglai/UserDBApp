import PhotosUI
import SwiftUI

struct RegistrationView: View {
    
    @EnvironmentObject private var registrationViewModel: RegistrationViewModel
    @EnvironmentObject private var positionSelectionViewModel: PositionSelectionViewModel
    @EnvironmentObject private var userInputViewModel: UserInputViewModel
    
    @Binding var selectedTab: UserDatabaseApp.Tab
    
    private var autorisationServise: AuthorisationService
    private var userStorage: UserStorage
    
    @State private var hasAppeared = false
    @State private var showSuccess = false
    @State private var showFailure = false
    
    init(registrationViewModel: RegistrationViewModel,
         autorisationServise: AuthorisationService,
         userStorage: UserStorage,
         selectedTab: Binding<UserDatabaseApp.Tab>) {
        self.autorisationServise = autorisationServise
        self.userStorage = userStorage
        self._selectedTab = selectedTab
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 20) {
                    HeaderView()
                    
                    TextFieldsView(
                        name: $registrationViewModel.name,
                        email: $registrationViewModel.email,
                        phone: $registrationViewModel.phone,
                        photo: $registrationViewModel.photoData
                    )
                    .environmentObject(registrationViewModel)
                    
                    PositionSelectionView(
                        selectedOption: $userInputViewModel.selectedOption,
                        positionId: $registrationViewModel.positionId
                    )
                    
                    PhotoUploadView(
                        userStorage: userStorage,
                        registrationViewModel: registrationViewModel
                    )
                    .environmentObject(registrationViewModel)
                    
                    SignUpButtonView(autorisationServise: autorisationServise)
                        .environmentObject(registrationViewModel)
                    
                    Spacer()
                }
            }
            .hideKeyboardOnTap()
            .onAppear {
                if selectedTab == .register {
                    registrationViewModel.errorMessage = nil
                    hasAppeared = true
                }
                Task {
                    await positionSelectionViewModel.loadPositions()
                }
            }
            .onReceive(registrationViewModel.$successRegistration) { register in
                guard hasAppeared else { return }
                if register == true {
                    showSuccess = true
                } else if register == false,
                          let error = registrationViewModel.errorMessage,
                          !error.isEmpty {
                    showFailure = true
                }
            }
            .onChange(of: selectedTab) { tab in
                if tab == .register {
                    registrationViewModel.resetForm()
                }
            }
            Spacer()
                .onChange(of: autorisationServise.token) { token in
                    if let selectedPosition = positionSelectionViewModel.positions.first(where: { $0.description == token }) {
                        registrationViewModel.position = selectedPosition
                    }
                    autorisationServise.isTokenFetched = true
                }
        }
        .fullScreenCover(isPresented: $showSuccess) {
            SignUpSuccessView()
        }
        .fullScreenCover(isPresented: $showFailure) {
            SignUpFailedView()
        }
    }
}

extension PhotosPickerItem: @retroactive Identifiable {
    public var id: String {
        self.itemIdentifier ?? UUID().uuidString
    }
}
extension View {
    func hideKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(
                #selector(UIResponder.resignFirstResponder),
                to: nil, from: nil, for: nil
            )
        }
    }
}

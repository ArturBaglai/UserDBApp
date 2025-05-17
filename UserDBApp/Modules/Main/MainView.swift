import SwiftUI

struct MainView: View {
    
    @State private var isLoading: Bool = false
    @State private var loadMoreInProgress: Bool = false   
    @State private var errorMessage: String? = nil
    @EnvironmentObject private var mainViewModel: MainViewModel

    var body: some View {
        NavigationView {
            VStack {
                ZStack {
                    Color.primaryYellow
                        .frame(height: 56)
                    
                    Text("Working with GET request")
                        .font(.headline)
                        .foregroundColor(.black)
                }

                if isLoading && mainViewModel.users.isEmpty {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                    
                } else if let errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else if mainViewModel.users.isEmpty {
                    UsersEmptyView()
                        .transition(.opacity)
                } else {
                    List {
                        ForEach($mainViewModel.users, id: \.id) { user in
                            if let photoUrl = user.wrappedValue.photoUrl.flatMap({ URL(string: $0) }) {
                                CardView(
                                    iconUrl: photoUrl,
                                    title: user.wrappedValue.name,
                                    subtitle: user.wrappedValue.position,
                                    email: user.wrappedValue.email,
                                    phone: user.wrappedValue.phone
                                )
                                .onAppear {
                                    if isLast(user: user.wrappedValue) && !loadMoreInProgress {
                                        Task {
                                            loadMoreInProgress = true
                                            await mainViewModel.loadMoreUsers()
                                            loadMoreInProgress = false
                                        }
                                    }
                                }
                            }
                        }
                        if loadMoreInProgress {
                            HStack {
                                Spacer()
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                                    .padding()
                                Spacer()
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .task {
                isLoading = true
                await mainViewModel.loadUsers()
                isLoading = false
            }
        }
    }

    func isLast(user: User) -> Bool {
        return user == mainViewModel.users.last
    }
}

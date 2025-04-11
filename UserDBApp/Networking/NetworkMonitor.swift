import Network

@MainActor
class NetworkMonitor: ObservableObject {
    static let shared = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue(label: "NetworkMonitorQueue")

    @Published var isConnected: Bool = false

    private init() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                let newStatus = path.status == .satisfied
                if self?.isConnected != newStatus {
                    self?.isConnected = newStatus
                }
            }
        }
        monitor.start(queue: queue)
    }
}

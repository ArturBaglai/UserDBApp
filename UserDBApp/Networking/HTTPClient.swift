import Foundation

extension HTTPClient {
    enum Method: String {
        case get = "GET"
        case post = "POST"
    }
}

class HTTPClient {
    
    func request<Response: Decodable>(
        url: URL,
        method: Method = .get,
        headers: [String: String]? = nil,
        body: Data? = nil
    ) async throws -> Response {
        
        guard await NetworkMonitor.shared.isConnected else {
            throw APIError.noInthernetConnection
        }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        if let headers = headers {
            for (key, value) in headers {
                request.setValue(value, forHTTPHeaderField: key)
                Logger.viewCycle.info("request: Header: \(key), value: \(value)")
            }
        }
        
    if let body {
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    }
    let (data, response) = try await URLSession.shared.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.unexpectedError(code: 0, message: "Invalid response")
        }
        Logger.viewCycle.info("request: Response status code: \(httpResponse.statusCode)")
        switch httpResponse.statusCode {
        case 200...299:
        return try JSONDecoder().decode(Response.self, from: data)

        case 201:
        throw APIError.unexpectedError(code: 201, message: "Success but resource created")
        case 401:
        throw APIError.expiredToken
        case 409:
        throw APIError.phoneOrEmailExists
        default:
            _ = String(data: data, encoding: .utf8) ?? "Unknown error"
        throw APIError.unexpectedError(code: httpResponse.statusCode, message: "Unexpected status code")
        }
    }
}

import Foundation
import UIKit

extension UserServiсe {
    enum Endpoint: String {
        case users = "/users"
        case positions = "/positions"
        case token = "/token"
    }
    enum UserError: Error {
        case pageError(message: String)
        case validationError(error: UserValidationErrorResponse)
        case networkError
    }
}

public class UserServiсe: ObservableObject {
    
    private let httpClient: HTTPClient
    private let baseURL = "https://frontend-test-assignment-api.abz.agency/api/v1"
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    func users(page: Int, count: Int) async throws -> GetUsersResponse {
        let urlString = "\(baseURL)\(Endpoint.users.rawValue)?page=\(page)&count=\(count)"
        
        guard let url = URL(string: urlString) else {
            throw APIError.unexpectedError(code: 0, message: "Invalid URL")
        }
        
        do {
            let result: GetUsersResponse = try await httpClient.request(url: url)
            return result
        } catch let error as APIError {
            if case let .unexpectedError(code, message) = error {
                let data = message.data(using: .utf8) ?? Data()
                
                switch code {
                case 404:
                  if let userError = try? JSONDecoder().decode(UserErrorResponse.self, from: data) {
                    throw  UserError.pageError(message: userError.message)
                  } else {
                    throw APIError.unexpectedError(code: 404, message: "Page not found")
                  }
                    
                case 422:
                  if let userError = try? JSONDecoder().decode(UserValidationErrorResponse.self, from: data) {
                      throw APIError.validationError(errors: userError)
                  } else {
                      throw APIError.unexpectedError(code: 422, message: "Validation error")
                  }
                    
                default:
                    throw error
                }
            }
            throw error
        }
    }

    func positions() async throws -> GetPositionsResponse {
        let urlString = "\(baseURL)\(Endpoint.positions.rawValue)"
        
        guard let url = URL(string: urlString) else {
            throw APIError.unexpectedError(code: 0, message: "Invalid URL.")
        }
        return try await httpClient.request(url: url)
        }
    
    func newUser(
        from endpoint: String,
        user: User,
        photoData: Data,
        token: String
    ) async throws -> NewUserSuccessResponse {
        return try await withCheckedThrowingContinuation { continuation in
            var multipart = MultipartRequest()
            
            multipart.add(key: "name", value: user.name)
            multipart.add(key: "email", value: user.email)
            multipart.add(key: "phone", value: user.phone)
            multipart.add(key: "position_id", value: user.positionId)

            if !photoData.isEmpty {
                multipart.add(
                    key: "photo",
                    fileName: "photo.jpg",
                    fileMimeType: "image/jpeg",
                    fileData: photoData
                )
            }
            guard let url = URL(string: "\(baseURL)/users") else {
                continuation.resume(throwing: APIError.unexpectedError(code: 0, message: "Invalid URL"))
                return
            }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue(multipart.httpContentTypeHeaderValue, forHTTPHeaderField: "Content-Type")
            request.setValue(token, forHTTPHeaderField: "Token")
            request.httpBody = multipart.httpBody

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    continuation.resume(throwing: APIError.unexpectedError(code: 0, message: error.localizedDescription))
                    return
                }

                guard let data = data else {
                    continuation.resume(throwing: APIError.noData)
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse else {
                    continuation.resume(throwing: APIError.unexpectedError(code: 0, message: "Invalid response"))
                    return
                }

                switch httpResponse.statusCode {
                case 200:
                  do {
                      let userResponse = try JSONDecoder().decode(NewUserSuccessResponse.self, from: data)
                      continuation.resume(returning: userResponse)
                      print(httpResponse.statusCode)
                  } catch {
                      continuation.resume(throwing: APIError.decodingError(error))
                      print(httpResponse.statusCode)
                  }
                case 401:
                  continuation.resume(throwing: APIError.expiredToken)
                case 409:
                  continuation.resume(throwing: APIError.phoneOrEmailExists)
                case 422:
                  do {
                      let decodedResponse = try JSONDecoder().decode(UserValidationErrorResponse.self, from: data)
                      continuation.resume(throwing: APIError.validationError(errors: decodedResponse))
                  } catch {
                      continuation.resume(throwing: APIError.unexpectedError(code: 422, message: "Failed to parse validation error"))
                  }
                default:
                  continuation.resume(throwing: APIError.unexpectedError(code: httpResponse.statusCode, message: "Something went wrong"))
                }
            }
            task.resume()
        }
    }
    private func validateUserInputs(user: User) -> Bool {
       
        guard user.name.count >= 2 && user.name.count <= 60 else { return false }
        
        let emailRegEx = "(?:[A-Za-z0-9]+(?:[._%+-]?[A-Za-z0-9])?)+@(?:[A-Za-z0-9-]+\\.)+[A-Za-z]{2,7}"
        
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        
        guard emailPredicate.evaluate(with: user.email) else { return false }
        
        guard user.positionId > 0 else { return false }
        
        
        guard user.phone.count <= 5 * 1024 else { return false }
        
        if let urlData = user.photoUrl,
           let data = urlData.data(using: .utf8),
           let image = UIImage(data: data),
           image.size.width >= 70, image.size.height >= 70
        {
            return true
        } else {
            return false
        }
    }
    
    func token(from endpoint: Endpoint) async throws -> GetTokenResponse {
        
        guard let url = URL(string: baseURL + endpoint.rawValue) else {
            throw APIError.unexpectedError(code: 0, message: "Invalid URL.")
        }
        return try await httpClient.request(url: url)
    }
}

struct UserErrorResponse: Codable {
    let success: Bool
    let message: String
}
    
struct NewUserSuccessResponse: Codable {
    let success: Bool
    let userId: Int
    let message: String
    
    enum CodingKeys: String, CodingKey{
        case success
        case userId = "user_id"
        case message
    }
}

struct UserValidationErrorResponse: Codable {
    var success: Bool
    var message: String
    var fails: [String: [String]]?
    
    func toString() -> String {
        var failsString = ""
        _ = fails.map { fails in
            for (key, value) in fails {
                failsString += key + ": "
                failsString += value.joined(separator: ", ")
            }
        }
        return "\(message)\n\(failsString)"
    }
}
struct UserValidationFails: Codable {
    let count: [String]?
    let page: [String]?
}
enum UserServiceError: Error {
    case invalidInput
    case noData
}

import Foundation

enum APIError: Error {
    case noInthernetConnection
    case expiredToken
    case phoneOrEmailExists
    case validationError(errors: UserValidationErrorResponse)
    case unexpectedError(code: Int, message: String)
    case noData
    case decodingError(Error)

    var message: String {
        switch self {
        
        case .noInthernetConnection:
            return "No internet connection"
        case .expiredToken:
            return "Token expired"
        case .phoneOrEmailExists:
            return "Phone or email already exists"
        case .validationError(let response):
            return "Validation errors: \(response.toString())"
        case .unexpectedError(code: let code, message: let message):
            return "Unexpected error: \(code) - \(message)"
        case .noData:
            return "No data"
        case .decodingError(let error):
            return "Decoding error: \(error)"
        }
    }
}

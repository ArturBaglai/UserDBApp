import Foundation

struct GetUsersResponse: Codable {
    let success: Bool
    let totalPages: Int
    let totalUsers: Int
    let count: Int
    let page: Int
    var links: Links
    let users: [User]

    enum CodingKeys: String, CodingKey {
        case success
        case totalPages = "total_pages"
        case totalUsers = "total_users"
        case count
        case page
        case links 
        case users 
    }
}
struct Links: Codable {
    let nextURL: String?
    let prevURL: String?

    enum CodingKeys: String, CodingKey {
        case nextURL = "next_url"
        case prevURL = "prev_url"
    }
}


import Foundation

struct User: Codable, Hashable {
    
    var id: Int
    var name: String
    var email: String
    var phone: String
    var position: String
    var positionId: Int
    var photoUrl: String?


    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case phone
        case position
        case positionId = "position_id"
        case photoUrl = "photo"
    }
}

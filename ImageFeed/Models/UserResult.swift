import Foundation

struct UserResult: Decodable {
    let profileImage: ProfileImageResult
}

struct ProfileImageResult: Decodable {
    let small: String
    let medium: String
    let large: String
}

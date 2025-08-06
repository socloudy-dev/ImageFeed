import Foundation

struct PhotoResult: Decodable {
    let id: String
    let width: Int
    let height: Int
    let createdAt: Date?
    let description: String?
    let urls: UrlsResult
    let likedByUser: Bool
    
    struct UrlsResult: Decodable {
        let thumb: String
        let regular: String
        let full: String
    }
}

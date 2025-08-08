import Foundation

struct Photo {
    let id: String
    let size: CGSize
    let createdAt: Date?
    let welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    let isLiked: Bool
    
    init(id: String, size: CGSize, createdAt: Date?, welcomeDescription: String?, thumbImageURL: String, largeImageURL: String, isLiked: Bool) {
            self.id = id
            self.size = size
            self.createdAt = createdAt
            self.welcomeDescription = welcomeDescription
            self.thumbImageURL = thumbImageURL
            self.largeImageURL = largeImageURL
            self.isLiked = isLiked
        }
    
    init(from result: PhotoResult) {
            let size = CGSize(width: result.width, height: result.height)
            self.init(
                id: result.id,
                size: size,
                createdAt: result.createdAt ?? Date(),
                welcomeDescription: result.description,
                thumbImageURL: result.urls.regular,
                largeImageURL: result.urls.full,
                isLiked: result.likedByUser
            )
        }
}

import Foundation

enum ImagesListServiceError: Error {
    case invalidRequest
    case decodingError(Error)
    case taskInProgress
    case networkError(Error)
}

final class ImagesListService {
    
    // MARK: - Properties
    
    var photos: [Photo] = []
    
    private var lastLoadedPage: Int?
    private var task: URLSessionTask?
    private let tokenStorage = OAuth2TokenStorage.shared
    private let urlSession = URLSession.shared
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    
    // MARK: - Setup Methods
    
    func fetchPhotosNextPage(completion: @escaping (Result<[PhotoResult], ImagesListServiceError>) -> Void) {
        let nextPage = (lastLoadedPage ?? 0) + 1
        if task != nil {
            return completion(.failure(ImagesListServiceError.taskInProgress))
        }
        
        guard let token = tokenStorage.token else { return }
        
        guard let request = makeImagesListRequest(token: token, page: nextPage) else {
            return completion(.failure(ImagesListServiceError.invalidRequest))
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            guard let self else { return }
            defer { self.task = nil }
            
            switch result {
            case .success(let result):
                
                let nextPagePhotos = result.map { Photo(from: $0) }
                
                let uniquePhotos = nextPagePhotos.filter { newPhoto in
                    !self.photos.contains(where: { $0.id == newPhoto.id })
                }
                
                DispatchQueue.main.async {
                    self.photos.append(contentsOf: uniquePhotos)
                    self.postNotification()
                    self.lastLoadedPage = nextPage
                }
                
                print("✅[ImagesListService/fetchPhotosNextPage]: Photos downloaded for page: \(nextPage)")
                
            case .failure(let error):
                print("‼️[ImagesListService/fetchPhotosNextPage]: Error when getting images list URLs: \(error.localizedDescription)")
                debugPrint(error)
                completion(.failure(ImagesListServiceError.networkError(error)))
            }
        }
        self.task = task
        task.resume()
    }
    
    private func makeImagesListRequest(token: String, page: Int) -> URLRequest? {
        guard let url = URL(string: "\(Constants.defaultBaseURLString)photos?page=\(page)") else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    private func postNotification() {
        NotificationCenter.default.post(name: ImagesListService.didChangeNotification, object: self)
        print("📤[ImagesListService/postNotification]: Notification posted.")
    }
    
    func changeLike(photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        if task != nil {
            return completion(.failure(ImagesListServiceError.taskInProgress))
        }
        
        guard let request = makeChangeLikeRequest(photoId: photoId, isLike: isLike) else {
            return
        }
        
        let task = urlSession.data(for: request) { [weak self] (result: Result<Data, Error>) in
            guard let self else { return }
            defer { self.task = nil }
            
            DispatchQueue.main.async {
                switch result {
                case .success:
                    if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                        let photo = self.photos[index]
                        let newPhoto = Photo(
                            id: photo.id,
                            size: photo.size,
                            createdAt: photo.createdAt,
                            welcomeDescription: photo.welcomeDescription,
                            thumbImageURL: photo.thumbImageURL,
                            largeImageURL: photo.largeImageURL,
                            isLiked: !photo.isLiked
                        )
                        
                        self.photos[index] = newPhoto
                        completion(.success(()))
                    }
                    
                    print("✅[ImagesListService/changeLike]: Like value is changed")
                    
                case .failure(let error):
                    print("‼️[ImagesListService/changeLike]: Error when changing isLiked state: \(error.localizedDescription)")
                    completion(.failure(ImagesListServiceError.networkError(error)))
                }
            }
        }
        self.task = task
        task.resume()
    }
    
    func makeChangeLikeRequest(photoId: String, isLike: Bool) -> URLRequest? {
        guard
            let url = URL(string: "\(Constants.defaultBaseURLString)photos/\(photoId)/like"),
            let token = tokenStorage.token
        else {
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = isLike ? "DELETE" : "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func clearImagesList() {
        photos = []
        lastLoadedPage = nil
    }
}

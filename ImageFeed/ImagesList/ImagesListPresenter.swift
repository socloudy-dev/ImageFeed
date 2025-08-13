import Foundation

protocol ImagesListPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    var photos: [Photo] { get set }
    func viewDidLoad()
    func updatePhotos() -> [IndexPath]
    func needNextPage(for indexPath: IndexPath)
    func didTapLike(at indexPath: IndexPath, for cell: ImagesListCell)
    func photo(at indexPath: IndexPath) -> Photo?
}

final class ImagesListPresenter: ImagesListPresenterProtocol {
    weak var view: ImagesListViewControllerProtocol?
    var photos: [Photo] = []
    private let imagesListService = ImagesListService()
    private var imagesListServiceObserver: NSObjectProtocol?
    var rowsCount: Int { photos.count }
    
    func viewDidLoad() {
        imagesListService.fetchPhotosNextPage() { result in
            switch result {
            case let .success(result):
                print("Fetching images done \(result)")
            case let .failure(error):
                print("Fetching images failure \(error)")
            }
        }
        
        imagesListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                let newIndexPaths = self.updatePhotos()
                guard !newIndexPaths.isEmpty else { return }
                self.view?.insertRows(at: newIndexPaths)
            }
    }
    
    func photo(at indexPath: IndexPath) -> Photo? {
            guard photos.indices.contains(indexPath.row) else { return nil }
            return photos[indexPath.row]
        }
    
    func needNextPage(for indexPath: IndexPath) {
          let lastRow = photos.count - 1
          guard indexPath.row >= lastRow else { return }
        imagesListService.fetchPhotosNextPage() { result in
            switch result {
            case let .success(result):
                print("Fetching images done \(result)")
            case let .failure(error):
                print("Fetching images failure \(error)")
            }
        }
      }
    
    func updatePhotos() -> [IndexPath] {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        photos = imagesListService.photos
        
        guard oldCount != newCount else { return [] }
        return (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
    }
    
    func didTapLike(at indexPath: IndexPath, for cell: ImagesListCell) {
        guard photos.indices.contains(indexPath.row) else { return }
        let photo = photos[indexPath.row]
        let newIsLike = !photo.isLiked

        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: newIsLike) { [weak self] result in
            guard let self else { return }
            defer { UIBlockingProgressHUD.dismiss() }

            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                cell.setIsLiked(self.photos[indexPath.row].isLiked)
                print("✅[ImagesListPresenter/didTapLike]: Like state is changed!")
            case .failure:
                print("‼️[ImagesListPresenter/didTapLike]: Error when change like state")
            }
        }
    }
}

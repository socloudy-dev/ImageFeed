import Foundation
@testable import ImageFeed

final class ImagePresenterSpy: ImagesListPresenterProtocol {
    var view: (any ImageFeed.ImagesListViewControllerProtocol)?
    
    var photos: [ImageFeed.Photo] = []
    var viewDidLoadCalled = false
    var didTapLikeCalled = false
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func updatePhotos() -> [IndexPath] {
        return []
    }
    
    func needNextPage(for indexPath: IndexPath) {
        
    }
    
    func didTapLike(at indexPath: IndexPath, for cell: ImageFeed.ImagesListCell) {
            didTapLikeCalled = true
    }
    
    func photo(at indexPath: IndexPath) -> ImageFeed.Photo? {
        return nil
    }
}

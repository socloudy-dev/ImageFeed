import XCTest
@testable import ImageFeed

final class ImagesListViewControllerTests: XCTestCase {
    func testViewControllerCallsViewDidLoad() {
        func testViewControllerCallsViewDidLoad() {
            // given
            let sb = UIStoryboard(name: "Main", bundle: Bundle(for: ImagesListViewController.self))
            let vc = sb.instantiateViewController(withIdentifier: "ImagesListViewController") as! ImagesListViewController

            let presenter = ImagePresenterSpy()
            vc.configure(presenter)

            // when
            vc.loadViewIfNeeded()

            // then
            XCTAssertTrue(presenter.viewDidLoadCalled)
        }
    }
    
    func testDidTapLikeCalled() {
        // given
        let viewController = ImagesListViewController()
        let presenter = ImagePresenterSpy()
        
        //when
        presenter.didTapLike(at: IndexPath(row: 0, section: 0), for: ImagesListCell())
        
        //then
        XCTAssertTrue(presenter.didTapLikeCalled)
    }
}

@testable import ImageFeed
import XCTest

final class ProfileTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoadOnPresenter() {
        //given
        let presenter = ProfilePresenterSpy()
        let viewController = ProfileViewController()
        viewController.configure(presenter)
        
        //when
        _ = viewController.view
        
        //then
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testDisplayProfileDetails() {
        //given
        let viewController = ProfileViewController()
        
        //when
        viewController.displayProfileDetails(with: "Имя пользователя", nickname: "nickname", description: "Доп. информация")
        
        //then
        XCTAssertEqual(viewController.nameLabel.text, "Имя пользователя")
        XCTAssertEqual(viewController.nicknameLabel.text, "nickname")
        XCTAssertEqual(viewController.descriptionLabel.text, "Доп. информация")        
    }
    
    func testLogoutButtonTapped() {
        //given
        let presenter = ProfilePresenterSpy()
        let viewController = ProfileViewController()
        
        //when
        viewController.configure(presenter)
        viewController.logoutButtonTapped()
        
        //then
        XCTAssertTrue(presenter.didLogoutButtonTapped)
    }
    
    
}

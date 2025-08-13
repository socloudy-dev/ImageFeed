import ImageFeed
import Foundation

final class ProfilePresenterSpy: ProfilePresenterProtocol  {
    var view: ProfileViewControllerProtocol?
    var viewDidLoadCalled = false
    var didLogoutButtonTapped = false
    
    
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    
    func logoutButtonTapped() {
        didLogoutButtonTapped = true
    }
    
    func logout() {
        
    }
}

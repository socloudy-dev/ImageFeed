import Foundation

public protocol ProfilePresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func logout()
    func logoutButtonTapped()
}

final class ProfilePresenter: ProfilePresenterProtocol {
    weak var view: ProfileViewControllerProtocol?
    
    private let profileService = ProfileService.shared
    private let tokenStorage = OAuth2TokenStorage.shared
    private let profileLogoutService = ProfileLogoutService.shared
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    func viewDidLoad() {
        if let profile = profileService.profile {
            updateProfileDetails(with: profile)
        }
        
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ProfileImageService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateAvatar()
            }
        
        updateAvatar()
    }
    
    func logoutButtonTapped() {
        view?.logoutAlert()
    }
    
    func logout() {
        self.profileLogoutService.logout()
    }
    
    private func updateProfileDetails(with profile: Profile) {
        let name = profile.name.isEmpty ? "Имя не указано" : profile.name
        let nickname = profile.loginName.isEmpty ? "@неизвестный_пользователь" : profile.loginName
        let description = (profile.bio?.isEmpty ?? true) ? "Профиль не заполнен" : (profile.bio ?? "")
        view?.displayProfileDetails(with: name, nickname: nickname, description: description)
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else {
            print("‼️[ProfilePresenter/updateAvatar]: Guard for image URL failed! URL is nil.")
            return
        }
        
        view?.updateAvatar(with: url)
    }
}

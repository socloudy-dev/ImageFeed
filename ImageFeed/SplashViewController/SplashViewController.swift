import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: - Properties
    
    private let storage = OAuth2TokenStorage.shared
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    
    private let splashImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "SplashScreen"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupSplashViews()
        setupSplashConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let token = storage.token {
            print("✅[SplashViewController/viewDidAppear]: Token is present, fetching profile.")
            
            fetchProfile(token: token)
        } else {
            presentAuthViewController()
        }
    }
    
    // MARK: - Setup ViewController Apperance
    
    private func setupSplashViews() {
        view.backgroundColor = UIColor(named: "YP Black")
        view.addSubview(splashImageView)
    }
    
    private func setupSplashConstraints() {
        splashImageView.widthAnchor.constraint(equalToConstant: 75).isActive = true
        splashImageView.heightAnchor.constraint(equalToConstant: 77).isActive = true
        splashImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        splashImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    // MARK: - Setup Methods
    
    func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else {
            assertionFailure("‼️[SplashViewController/switchToTabBarController]: Invalid window configuration")
            return
        }
        
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    
    private func presentAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authViewController = storyboard.instantiateViewController(withIdentifier: "AuthViewController") as? AuthViewController else {
            assertionFailure("‼️[SplashViewController/presentAuthViewController]: Cannot find AuthViewController by identifier.")
            return
        }
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController, with code: String) {
        vc.dismiss(animated: true)
        
        guard let token = storage.token else {
            print("⚠️[SplashViewController/didAuthenticate]: Token is empty. Profile can't be downloaded.")
            return
        }
        
        fetchProfile(token: token)
    }
    
    private func fetchProfile(token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            
            guard let self = self else { return }
            
            switch result {
            case let .success(profile):
                profileImageService.fetchProfileImageURL(username: profile.username) { _ in }
                DispatchQueue.main.async {
                    self.switchToTabBarController()
                }
                
            case let .failure(error):
                print("‼️[SplashViewController/fetchProfile]: Error when called fetchProfile function: \(error)")
                //self.switchToTabBarController()
                break
            }
        }
    }
}

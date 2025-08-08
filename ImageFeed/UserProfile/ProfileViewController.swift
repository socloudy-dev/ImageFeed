import UIKit
import Kingfisher

final class ProfileViewController: UIViewController {
    
    // MARK: - Properties
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "UserPhoto"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Екатерина Новикова"
        label.font = UIFont.boldSystemFont(ofSize: 23)
        label.textColor = UIColor(named: "YP White")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let nicknameLabel: UILabel = {
        let label = UILabel()
        label.text = "@ekaterina_nov"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(named: "YP Gray")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Hello, world!"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(named: "YP White")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private let logoutButton: UIButton = {
        let buttonImage = UIImage(named: "Exit Button")
        guard let buttonImage else { return UIButton() }
        
        let button = UIButton.systemButton(
            with: buttonImage,
            target: self,
            action: #selector(Self.logoutButtonTapped))
        button.tintColor = UIColor(named: "YP Red")
        
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let profileService = ProfileService.shared
    private let tokenStorage = OAuth2TokenStorage.shared
    private let profileLogoutService = ProfileLogoutService.shared
    
    private var profileImageServiceObserver: NSObjectProtocol?
    
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        setupProfileViews()
        setupProfileConstraints()
    }
    
    // MARK: - Setup ViewController Apperance
    
    private func setupProfileViews() {
        view.backgroundColor = UIColor(named: "YP Black")
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(nicknameLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(logoutButton)
    }
    
    private func setupProfileConstraints() {
        profileImageView.widthAnchor.constraint(equalToConstant: 70).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        profileImageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        profileImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32).isActive = true
        
        nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 8).isActive = true
        nameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        
        nicknameLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8).isActive = true
        nicknameLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        
        descriptionLabel.topAnchor.constraint(equalTo: nicknameLabel.bottomAnchor, constant: 8).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16).isActive = true
        
        logoutButton.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        logoutButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16).isActive = true
    }
    
    // MARK: - Setup Methods
    
    private func updateProfileDetails(with profile: Profile) {
        nameLabel.text = profile.name.isEmpty ? "Имя не указано" : profile.name
        nicknameLabel.text = profile.loginName.isEmpty ? "@неизвестный_пользователь" : profile.loginName
        descriptionLabel.text = (profile.bio?.isEmpty ?? true) ? "Профиль не заполнен" : profile.bio
    }
    
    private func updateAvatar() {
        guard
            let profileImageURL = ProfileImageService.shared.avatarURL,
            let url = URL(string: profileImageURL)
        else {
            print("‼️[ProfileViewController/updateAvatar]: Guard for image URL failed! URL is nil.")
            return
        }
        
        let placeholderImage = UIImage(systemName: "person.circle.fill")?
            .withTintColor(.lightGray, renderingMode: .alwaysOriginal)
            .withConfiguration(UIImage.SymbolConfiguration(pointSize: 70, weight: .regular, scale: .large))
        
        let processor = RoundCornerImageProcessor(cornerRadius: 35)
        profileImageView.kf.indicatorType = .activity
        profileImageView.kf.setImage(
            with: url,
            placeholder: placeholderImage,
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
                .forceRefresh
            ]) { result in
                
                switch result {
                case .success(let value):
                    print(value.image)
                    print(value.cacheType)
                    print(value.source)
                    
                case .failure(let error):
                    print(error)
                }
            }
    }
    
    private func logoutAlert() {
        let alert = UIAlertController(title: "Пока, Пока!", message: "Уверены что хотите выйти?", preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Да", style: .cancel) { _ in
            self.profileLogoutService.logout() { [weak self] in
                UIBlockingProgressHUD.dismiss()
                self?.navigateToSplashScreen()
            }
        }
        let noAction = UIAlertAction(title: "Нет", style: .default, handler: nil)
        
        alert.addAction(yesAction)
        alert.addAction(noAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func navigateToSplashScreen() {
            DispatchQueue.main.async {
                guard let window = UIApplication.shared.windows.first else {
                    print("‼️[ProfileLogoutService/navigateToSplashScreen]: Error when getting main window")
                    return
                }
                let initialViewController = SplashViewController()
                window.rootViewController = initialViewController
                window.makeKeyAndVisible()
            }
        }
    // MARK: - Actions
    
    @objc private func logoutButtonTapped() {
        logoutAlert()
        print("Logout button tapped!")
    }
}

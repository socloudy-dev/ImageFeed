import Foundation
import WebKit
import SwiftKeychainWrapper
import Kingfisher

final class ProfileLogoutService {
    static let shared = ProfileLogoutService()
    
    private init() { }
    
    private let profileService = ProfileService.shared
    private let profileImageService = ProfileImageService.shared
    private let imagesListService = ImagesListService()
    
    private let tokenStorage = OAuth2TokenStorage.shared
    
    func logout() {
        cleanCookies()
        tokenStorage.token = nil
        profileService.clearProfileData()
        profileImageService.clearAvatarURL()
        imagesListService.clearImagesList()
        KingfisherManager.shared.cache.clearMemoryCache()
        KingfisherManager.shared.cache.clearDiskCache()
        navigateToSplashScreen()
    }
    
    private func cleanCookies() {
        HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
        WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
            records.forEach { record in
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
            }
        }
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
}

import Foundation

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private init() {}
    
    private let storage: UserDefaults = .standard
    private let tokenKey: String = "OAuthToken"
    
    var token: String? {
        get {
            return storage.string(forKey: tokenKey)
        } set {
            storage.set(newValue, forKey: tokenKey)
        }
    }
    
    func store(receivedToken: String) {
        token = receivedToken
    }
}

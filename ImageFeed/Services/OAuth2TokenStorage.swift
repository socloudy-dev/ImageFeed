import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private init() {}
    
    private let tokenKey: String = "OAuthToken"
    
    var token: String? {
        get {
            return KeychainWrapper.standard.string(forKey: tokenKey)
        }
        set {
            if let token = newValue {
                KeychainWrapper.standard.set(token, forKey: tokenKey)
            } else {
                KeychainWrapper.standard.removeObject(forKey: tokenKey)
            }
        }
    }
    /*
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
     */
}

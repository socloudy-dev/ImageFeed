import Foundation

enum Constants {
    static let accessKey = "ccyeB06xUGDQkiKxi2WcyQQWGwAJG_C7rCwb9F_ECqY"
    static let secretKey = "eXh5_pZGPVlCTIKNPeZE-ucaPXJLsIa7gAr1ik0ThKE"
    static let redirectURI = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope = "public+read_user+write_likes"
    
    static let defaultBaseURL = URL(string: "https://api.unsplash.com/")
    static let defaultBaseURLString = "https://api.unsplash.com/"
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let defaultBaseURLString: String
    let authURLString: String
    
    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, defaultBaseURL: URL, defaultBaseURLString: String, authURLString: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.defaultBaseURLString = defaultBaseURLString
        self.authURLString = authURLString
    }
    
    static var standard: AuthConfiguration {
        return AuthConfiguration(accessKey: Constants.accessKey,
                                 secretKey: Constants.secretKey,
                                 redirectURI: Constants.redirectURI,
                                 accessScope: Constants.accessScope,
                                 defaultBaseURL: Constants.defaultBaseURL!,
                                 defaultBaseURLString: Constants.defaultBaseURLString,
                                 authURLString: Constants.unsplashAuthorizeURLString)
    }
}

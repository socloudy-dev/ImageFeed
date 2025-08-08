import UIKit
import ProgressHUD

final class UIBlockingProgressHUD {
    private static var window: UIWindow? {
        return UIApplication.shared.windows.first
    }
    
    static func setupActivityIndicator() {
        guard
            let ypBlack = UIColor(named: "YP Black"),
            let ypWhite = UIColor(named: "YP White")
        else { return }
        ProgressHUD.animationType = .activityIndicator
        ProgressHUD.colorHUD = ypWhite
        ProgressHUD.colorAnimation = ypBlack
    }
    
    static func show() {
        setupActivityIndicator()
        window?.isUserInteractionEnabled = false
        ProgressHUD.animate()
    }
    
    static func dismiss() {
        window?.isUserInteractionEnabled = true
        ProgressHUD.dismiss()
    }
}

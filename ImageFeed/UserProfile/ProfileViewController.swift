import UIKit

final class ProfileViewController: UIViewController {
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var profileDescriptionLabel: UILabel!
    @IBOutlet weak var userNicknameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var logoutButton: UIButton!
    
    //MARK: - Properties
    
    
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    
    
    //MARK: - ViewController Extensions
    
    
    //MARK: - IBActions
    
    @IBAction func didUserTapLogoutButton(_ sender: Any) {
    }
    
    
}

import UIKit

final class ImagesListCell: UITableViewCell {
    @IBOutlet public weak var imageIntoTheCell: UIImageView!
    @IBOutlet public weak var dateLabel: UILabel!
    @IBOutlet public weak var likeButton: UIButton!
    
    static let reuseIdentifier = "ImagesListCell"
}

import UIKit
import Kingfisher

protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    @IBOutlet public weak var imageIntoTheCell: UIImageView!
    @IBOutlet public weak var dateLabel: UILabel!
    @IBOutlet public weak var likeButton: UIButton!
    
    weak var delegate: ImagesListCellDelegate?
    static let reuseIdentifier = "ImagesListCell"
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageIntoTheCell.image = nil
        dateLabel.text = nil
        
        likeButton.setImage(nil, for: .normal)
    }
    
    func setIsLiked(_ isLiked: Bool) {
            let buttonImage = isLiked ? UIImage(named: "Like Button On") : UIImage(named: "Like Button Off")
            likeButton.setImage(buttonImage, for: .normal)
        }
    
    @IBAction private func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
}

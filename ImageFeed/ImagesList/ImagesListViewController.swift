import UIKit

final class ImagesListViewController: UIViewController {
    
    //MARK: - IBOutlets
    @IBOutlet private var imageListTableView: UITableView!
    
    //MARK: - Properties
    
    private let photosName: [String] = Array(0..<20).map{ "\($0)"}
    private let imageInsets = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    //MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageListTableView.rowHeight = 300
        imageListTableView.contentInset = imageInsets
    }
    
    
    
    //MARK: - Setup Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination!")
                return
            }
            
            let image = UIImage(named: photosName[indexPath.row])
            viewController.image = image
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
}

//MARK: - ViewController Extensions

extension ImagesListViewController {
    func configCell(for cell: ImagesListCell, with indexPath: IndexPath) {
        guard let currentImage = UIImage(named: photosName[indexPath.row]) else {
            return
        }
        let currentDate = Date()
        
        cell.imageIntoTheCell.image = currentImage
        cell.dateLabel.text = dateFormatter.string(from: currentDate)
        
        let isItEven = indexPath.row % 2 == 0
        let likeButtonImageName = isItEven ?
        "Like Button On" : "Like Button Off"
        cell.likeButton.setImage(UIImage(named: likeButtonImageName), for: .normal)
    }
}

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let currentImage = UIImage(named: photosName[indexPath.row]) else {
            return 0
        }
        
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = currentImage.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = currentImage.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photosName.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        configCell(for: imageListCell, with: indexPath)
        return imageListCell
    }
}

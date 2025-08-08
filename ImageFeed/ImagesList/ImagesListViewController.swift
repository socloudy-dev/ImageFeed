import UIKit
import Kingfisher

final class ImagesListViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet private var imageListTableView: UITableView!
    
    // MARK: - Properties
    
    var photos: [Photo] = []
    private let imageInsets = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let imagesListService = ImagesListService()
    private var imagesListServiceObserver: NSObjectProtocol?
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagesListService.fetchPhotosNextPage() { result in
            switch result {
            case let .success(result):
                print("Fetching images done \(result)")
            case let .failure(error):
                print("Fetching images failure \(error)")
            }
        }
        
        imagesListServiceObserver = NotificationCenter.default
            .addObserver(
                forName: ImagesListService.didChangeNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                guard let self = self else { return }
                self.updateTableViewAnimated()
            }
        
        imageListTableView.rowHeight = 300
        imageListTableView.contentInset = imageInsets
    }
    
    // MARK: - Setup Methods
    
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        self.photos = imagesListService.photos
        if oldCount != newCount {
            imageListTableView.performBatchUpdates {
                let indexPaths = (oldCount..<newCount).map { i in
                    IndexPath(row: i, section: 0)
                }
                imageListTableView.insertRows(at: indexPaths, with: .automatic)
            } completion: { _ in }
        }
    }
    
    private func showSingleImageView(url: String) {
        let singleImageController = SingleImageViewController()
        singleImageController.largeImageURL = url
        singleImageController.modalPresentationStyle = .fullScreen
        present(singleImageController, animated: true)
    }
   
    // MARK: - Overrided functions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier,
           let viewController = segue.destination as? SingleImageViewController,
           let indexPath = sender as? IndexPath
        {
            let photo = photos[indexPath.row]
            viewController.largeImageURL = photo.largeImageURL
        }
    }
}

// MARK: - ViewController Extensions

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let photo = photos[indexPath.row]
        
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = CGFloat(photo.size.width)
        let imageHeight = CGFloat(photo.size.height)
        let scale = imageViewWidth / imageWidth
        let cellHeight = imageHeight * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard indexPath.row == photos.count - 1 else { return }
        
        imagesListService.fetchPhotosNextPage() { result in
            switch result {
            case let .success(result):
                print("Fetching images done \(result)")
            case let .failure(error):
                print("Fetching images failure \(error)")
            }
        }
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        imageListCell.delegate = self
        
        let photo = photos[indexPath.row]
        let url = photo.thumbImageURL
        
        imageListCell.imageIntoTheCell.kf.indicatorType = .activity
        imageListCell.imageIntoTheCell.kf.setImage(
            with: URL(string: url),
            placeholder: UIImage(named: "Placeholder"),
            options: nil,
            completionHandler: { _ in
                tableView.beginUpdates()
                tableView.endUpdates()
            }
        )
        imageListCell.dateLabel.text = dateFormatter.string(from: photo.createdAt ?? Date())
        
        let likeImage = photo.isLiked ? "Like Button On" : "Like Button Off"
        imageListCell.likeButton.setImage(UIImage(named: likeImage), for: .normal)
        
        return imageListCell
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = imageListTableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(photoId: photo.id, isLike: !photo.isLiked) { result in
            defer { UIBlockingProgressHUD.dismiss() }
            
            switch result {
            case .success:
                self.photos = self.imagesListService.photos
                cell.setIsLiked(self.photos[indexPath.row].isLiked)
                print("✅[ImagesListViewController/imageListCellDidTapLike]: Like state is changed!")
            case .failure:
                print("‼️[ImagesListViewController/imageListCellDidTapLike]: Error when change like state")
            }
        }
    }
}

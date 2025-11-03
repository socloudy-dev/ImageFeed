import UIKit
import Kingfisher

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListPresenterProtocol? { get set }
    
    func insertRows(at IndexPaths: [IndexPath])
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol {
    
    // MARK: - IBOutlets
    @IBOutlet private var imageListTableView: UITableView!
    
    // MARK: - Properties
    
    var presenter: ImagesListPresenterProtocol?
    private let imageInsets = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    
    private lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter
    }()
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter?.viewDidLoad()
        imageListTableView.rowHeight = 300
        imageListTableView.contentInset = imageInsets
    }
    
    // MARK: - Setup Methods
    
    func configure(_ presenter: ImagesListPresenterProtocol) {
        self.presenter = presenter
    }
    
    func insertRows(at indexPaths: [IndexPath]) {
        imageListTableView.insertRows(at: indexPaths, with: .automatic)
    }
    
    func updateTableViewAnimated() {
        guard let indexPaths = presenter?.updatePhotos() else { return }
        if !indexPaths.isEmpty {
            imageListTableView.performBatchUpdates {
                insertRows(at: indexPaths)
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
            guard let photo = presenter?.photos[indexPath.row] else { return }
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
        guard let photo = presenter?.photo(at: indexPath) else { return 0 }
    
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = CGFloat(photo.size.width)
        let imageHeight = CGFloat(photo.size.height)
        let scale = imageViewWidth / imageWidth
        let cellHeight = imageHeight * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        presenter?.needNextPage(for: indexPath)
    }
}

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter?.photos.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        
        imageListCell.delegate = self
        
        guard let photo = presenter?.photo(at: indexPath) else { return UITableViewCell() }
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
        guard
            let indexPath = imageListTableView.indexPath(for: cell),
            let presenter
        else { return }
        presenter.didTapLike(at: indexPath, for: cell)
    }
}

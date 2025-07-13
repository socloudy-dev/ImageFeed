import UIKit

final class SingleImageViewController: UIViewController {
    
    //MARK: - Properties
    
    var image: UIImage? {
        didSet {
            guard isViewLoaded else { return }
            singleImage.image = image
            guard let unwrappedImage = singleImage.image else { return }
            rescaleAndCenterImageInScrollView(image: unwrappedImage)
        }
    }
    
    //MARK: - IBOutlets
    
    @IBOutlet private weak var scrollViewOfSingleImage: UIScrollView!
    @IBOutlet private weak var backwardButton: UIButton!
    @IBOutlet private var singleImage: UIImageView!
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        singleImage.image = image
        guard let unwrappedImage = singleImage.image else { return }
        singleImage.frame.size = unwrappedImage.size
        scrollViewOfSingleImage.minimumZoomScale = 0.1
        scrollViewOfSingleImage.maximumZoomScale = 1.25
        
        rescaleAndCenterImageInScrollView(image: unwrappedImage)
        scrollViewDidZoom(scrollViewOfSingleImage)
    }
    
    //MARK: - Sethup Methods
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollViewOfSingleImage.minimumZoomScale
        let maxZoomScale = scrollViewOfSingleImage.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollViewOfSingleImage.bounds.size
        let imageSize = image.size
        let hScale = imageSize.width != 0 ? visibleRectSize.width / imageSize.width : 1
        let vScale = imageSize.height != 0 ? visibleRectSize.height / imageSize.height : 1
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        scrollViewOfSingleImage.setZoomScale(scale, animated: false)
        scrollViewOfSingleImage.layoutIfNeeded()
        let newContentSize = scrollViewOfSingleImage.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollViewOfSingleImage.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    private func updateContentInset() {
        let scrollViewSize = scrollViewOfSingleImage.bounds.size
        let imageSize = singleImage.frame.size
        
        let verticalInset = imageSize.height < scrollViewSize.height ?
        (scrollViewSize.height - imageSize.height) / 2 : 0
        let horizontalInset = imageSize.width < scrollViewSize.width ?
        (scrollViewSize.width - imageSize.width) / 2 : 0
        
        scrollViewOfSingleImage.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }
    //MARK: - IBActions
    
    @IBAction func didTapBackButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    //новое
    @IBAction func didTapShareButton(_ sender: Any) {
        guard let image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        present(share, animated: true, completion: nil)
    }
}


//MARK: - SingleImageViewController Extensions

extension SingleImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return singleImage
    }
    func scrollViewDidZoom(_: UIScrollView) {
        updateContentInset()
    }
}

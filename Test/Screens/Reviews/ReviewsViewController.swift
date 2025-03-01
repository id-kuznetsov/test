import UIKit

final class ReviewsViewController: UIViewController {
    
    private lazy var reviewsView = makeReviewsView()
    private let viewModel: ReviewsViewModel
    
    init(viewModel: ReviewsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = reviewsView
        title = "Отзывы"
        navigationItem.leftBarButtonItem = UIBarButtonItem()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reviewsView.startLoading()
        setupViewModel()
        setupRefreshControl()
        viewModel.getReviews()
    }
    
}

// MARK: - Private

private extension ReviewsViewController {
    
    func makeReviewsView() -> ReviewsView {
        let reviewsView = ReviewsView()
        reviewsView.tableView.delegate = viewModel
        reviewsView.tableView.dataSource = viewModel
        return reviewsView
    }
    
    func setupViewModel() {
        viewModel.onStateChange = { [weak self] newState in
            guard let self else { return }
            
            let oldCount = self.reviewsView.tableView.numberOfRows(inSection: 0) 
            let newCount = newState.items.count
            
            if oldCount < newCount {
                self.reviewsView.stopLoading()
                self.reviewsView.updateTableViewAnimated(from: oldCount, to: newCount)
            } else {
                self.reviewsView.tableView.reloadData()
            }
            self.reviewsView.refreshControl.endRefreshing()
            self.reviewsView.reviewsFooter.updateText(reviewsCount: newState.items.count)
        }
        
        viewModel.onShowPhotoFullscreen = { [weak self] index, photoUrls in
            guard index < photoUrls.count else { return }
            let photoUrl = photoUrls[index]
            let viewModel = SinglePhotoViewModel(imageProvider: ImageProvider.shared)
            let singlePhotoViewer = SinglePhotoViewController(viewModel: viewModel)
            singlePhotoViewer.setPhotoFromURL(fullImageStringURL: photoUrl)
            singlePhotoViewer.modalPresentationStyle = .fullScreen
            self?.present(singlePhotoViewer, animated: true)
        }
    }
    
    private func setupRefreshControl() {
        reviewsView.refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    @objc
    private func refreshData() {
        viewModel.refreshReviews { [weak self] in
            self?.reviewsView.stopLoading()
            self?.reviewsView.refreshControl.endRefreshing()
        }
    }
    
}

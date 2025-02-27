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
            self.reviewsView.stopLoading()
            let oldCount = self.reviewsView.tableView.numberOfRows(inSection: 0) - 1
            let newCount = newState.items.count
            
            if oldCount < newCount {
                self.reviewsView.updateTableViewAnimated(from: oldCount, to: newCount)
            } else {
                self.reviewsView.tableView.reloadData()
            }
            self.reviewsView.refreshControl.endRefreshing()
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

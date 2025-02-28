import UIKit

final class ReviewsView: UIView {

    let tableView = UITableView()
    let refreshControl = UIRefreshControl()
    
    lazy var reviewsFooter = ReviewsFooterView(
        frame: CGRect(
            x: 0,
            y: 0,
            width: tableView.frame.width,
            height: 30
        )
    )
    
    private lazy var activityIndicator: LoadingView = {
        let indicator = LoadingView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        tableView.frame = bounds.inset(by: safeAreaInsets)
        activityIndicator.center = center
    }
    
    func updateTableViewAnimated(from oldCount: Int, to newCount: Int) {
        tableView.performBatchUpdates {
            let indexPaths = (oldCount..<newCount).map { IndexPath(row: $0, section: 0) }
            tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
    
    func startLoading() {
        activityIndicator.isHidden = false
        tableView.isHidden = true
    }

    func stopLoading() {
        activityIndicator.isHidden = true
        tableView.isHidden = false
    }

}

// MARK: - Private

private extension ReviewsView {

    func setupView() {
        backgroundColor = .systemBackground
        setupTableView()
        setupActivityIndicator()
    }

    func setupTableView() {
        addSubview(tableView)
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.register(ReviewCell.self, forCellReuseIdentifier: ReviewCellConfig.reuseId)
        tableView.refreshControl = refreshControl
        tableView.tableFooterView = reviewsFooter
    }
    
    func setupActivityIndicator() {
        addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

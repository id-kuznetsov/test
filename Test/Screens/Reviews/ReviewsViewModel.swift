import UIKit

/// Класс, описывающий бизнес-логику экрана отзывов.
final class ReviewsViewModel: NSObject {
    
    /// Замыкание, вызываемое при изменении `state`.
    var onStateChange: ((State) -> Void)?
    /// Замыкание для показа фото в полноэкранном режиме.
    var onShowPhotoFullscreen: ((Int, [String]) -> Void)?
    
    private var state: State
    private let reviewsProvider: ReviewsProvider
    private let ratingRenderer: RatingRenderer
    private let imageProvider = ImageProvider.shared
    private let decoder: JSONDecoder
    
    init(
        state: State = State(),
        reviewsProvider: ReviewsProvider = ReviewsProvider(),
        ratingRenderer: RatingRenderer = RatingRenderer(),
        decoder: JSONDecoder = SnakeCaseJSONDecoder()
    ) {
        self.state = state
        self.reviewsProvider = reviewsProvider
        self.ratingRenderer = ratingRenderer
        self.decoder = decoder
    }
    
}

// MARK: - Internal

extension ReviewsViewModel {
    
    typealias State = ReviewsViewModelState
    
    /// Метод получения отзывов.
    func getReviews() {
        guard state.shouldLoad else { return }
        state.shouldLoad = false
        reviewsProvider.getReviews(offset: state.offset, completion: gotReviews)
    }
    
    func refreshReviews(completion: @escaping () -> Void) {
        state = State()
        getReviews()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            completion()
        }
    }
    
}

// MARK: - Private

private extension ReviewsViewModel {
    
    /// Метод обработки получения отзывов.
    private func gotReviews(_ result: ReviewsProvider.GetReviewsResult) {
        do {
            let data = try result.get()
            let reviews = try self.decoder.decode(Reviews.self, from: data)
            let newReviews = reviews.items.prefix(reviews.count - self.state.items.count)
            let mappedReviews = newReviews.map(self.makeReviewItem)
            
            self.state.items.append(contentsOf: mappedReviews)
            self.state.offset += newReviews.count
            self.state.shouldLoad = self.state.offset < reviews.count
            self.onStateChange?(self.state)
        } catch {
            self.state.shouldLoad = true
            self.onStateChange?(self.state)
        }
    }
    
    /// Метод, вызываемый при нажатии на кнопку "Показать полностью...".
    /// Снимает ограничение на количество строк текста отзыва (раскрывает текст).
    func showMoreReview(with id: UUID) {
        guard
            let index = state.items.firstIndex(where: { ($0 as? ReviewItem)?.id == id }),
            var item = state.items[index] as? ReviewItem
        else { return }
        item.maxLines = .zero
        state.items[index] = item
        onStateChange?(state)
    }
    
    func showPhotoFullscreen(with index: Int, photoUrls: [String]) {
        onShowPhotoFullscreen?(index, photoUrls)
    }
    
    func makeOnTapPhoto(for photoUrls: [String]) -> (Int) -> Void {
        return { [weak self] index in
            self?.showPhotoFullscreen(with: index, photoUrls: photoUrls)
        }
    }
}

// MARK: - Items

private extension ReviewsViewModel {
    
    typealias ReviewItem = ReviewCellConfig
    
    func makeReviewItem(_ review: Review) -> ReviewItem {
        let fullName = ("\(review.firstName) \(review.lastName)").attributed(font: .username)
        let reviewText = review.text.attributed(font: .text)
        let created = review.created.attributed(font: .created, color: .created)
        let ratingImage = ratingRenderer.ratingImage(review.rating)
        
        let item = ReviewItem(
            avatarUrl: review.avatarUrl,
            fullName: fullName,
            ratingImage: ratingImage,
            photoUrls: review.photosUrls,
            reviewText: reviewText,
            created: created,
            onTapShowMore: showMoreReview,
            onTapPhoto: makeOnTapPhoto(for: review.photosUrls ?? [])
        )
        return item
        
    }
}

// MARK: - UITableViewDataSource

extension ReviewsViewModel: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        state.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < state.items.count else {
            return UITableViewCell()
        }
        let config = state.items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: config.reuseId, for: indexPath)
        config.update(cell: cell)
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension ReviewsViewModel: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.row < state.items.count else {
            return 0
        }
        return state.items[indexPath.row].height(with: tableView.bounds.size)
    }
    
    /// Метод дозапрашивает отзывы, если до конца списка отзывов осталось два с половиной экрана по высоте.
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        if shouldLoadNextPage(scrollView: scrollView, targetOffsetY: targetContentOffset.pointee.y) {
            getReviews()
        }
    }
    
    private func shouldLoadNextPage(
        scrollView: UIScrollView,
        targetOffsetY: CGFloat,
        screensToLoadNextPage: Double = 2.5
    ) -> Bool {
        let viewHeight = scrollView.bounds.height
        let contentHeight = scrollView.contentSize.height
        let triggerDistance = viewHeight * screensToLoadNextPage
        let remainingDistance = contentHeight - viewHeight - targetOffsetY
        return remainingDistance <= triggerDistance
    }
    
}

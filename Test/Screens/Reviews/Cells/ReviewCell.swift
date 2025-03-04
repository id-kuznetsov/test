import UIKit

/// Конфигурация ячейки. Содержит данные для отображения в ячейке.
struct ReviewCellConfig {
    
    /// Идентификатор для переиспользования ячейки.
    static let reuseId = String(describing: ReviewCellConfig.self)
    /// Ссылка на аватар.
    let avatarUrl: String
    /// Полное имя
    let fullName: NSAttributedString
    /// Рейтинг
    let ratingImage: UIImage
    /// Ссылки на фото к отзыву
    let photoUrls: [String]?
    /// Идентификатор конфигурации. Можно использовать для поиска конфигурации в массиве.
    let id = UUID()
    /// Текст отзыва.
    let reviewText: NSAttributedString
    /// Максимальное отображаемое количество строк текста. По умолчанию 3.
    var maxLines = 3
    /// Время создания отзыва.
    let created: NSAttributedString
    /// Замыкание, вызываемое при нажатии на кнопку "Показать полностью...".
    let onTapShowMore: (UUID) -> Void
    /// Замыкание, вызываемое при нажатии на фото.
    let onTapPhoto: (Int) -> Void
    
    /// Объект, хранящий посчитанные фреймы для ячейки отзыва.
    fileprivate let layout = ReviewCellLayout()
    
}

// MARK: - TableCellConfig

extension ReviewCellConfig: TableCellConfig {
    
    /// Метод обновления ячейки.
    /// Вызывается из `cellForRowAt:` у `dataSource` таблицы.
    func update(cell: UITableViewCell) {
        guard let cell = cell as? ReviewCell else { return }
        
        if let avatarUrl = URL(string: avatarUrl) {
            ImageProvider.shared.loadImage(from: avatarUrl, targetSize: CGSize(width: 36.0, height: 36.0)) { image in
                    cell.avatarView.image = image ?? UIImage(named: "avatarPlaceholder")
            }
        }
        cell.usernameLabel.attributedText = fullName
        cell.ratingView.image = ratingImage
        cell.photosCollectionView.setPhotos(photoUrls)
        cell.reviewTextLabel.attributedText = reviewText
        cell.reviewTextLabel.numberOfLines = maxLines
        cell.createdLabel.attributedText = created
        cell.config = self
    }
    
    /// Метод, возвращаюший высоту ячейки с данным ограничением по размеру.
    /// Вызывается из `heightForRowAt:` делегата таблицы.
    func height(with size: CGSize) -> CGFloat {
        layout.height(config: self, maxWidth: size.width)
    }
    
}

// MARK: - Private

private extension ReviewCellConfig {
    
    /// Текст кнопки "Показать полностью...".
    static let showMoreText = "Показать полностью..."
        .attributed(font: .showMore, color: .showMore)
    
}

// MARK: - Cell

final class ReviewCell: UITableViewCell {
    
    fileprivate var config: Config?
    
    fileprivate let avatarView = UIImageView()
    fileprivate let usernameLabel = UILabel()
    fileprivate let ratingView = UIImageView()
    fileprivate let photosCollectionView = ReviewPhotosCollectionView()
    fileprivate let reviewTextLabel = UILabel()
    fileprivate let createdLabel = UILabel()
    fileprivate let showMoreButton = UIButton()
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        usernameLabel.text = nil
        reviewTextLabel.text = nil
        createdLabel.text = nil
        ratingView.image = nil
        avatarView.image = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard let layout = config?.layout else { return }
        avatarView.frame = layout.avatarFrame
        usernameLabel.frame = layout.usernameLabelFrame
        ratingView.frame = layout.ratingFrame
        photosCollectionView.frame = layout.photosCollectionViewFrame
        reviewTextLabel.frame = layout.reviewTextLabelFrame
        createdLabel.frame = layout.createdLabelFrame
        showMoreButton.frame = layout.showMoreButtonFrame
    }
    
}

extension ReviewCell: ReviewPhotosCollectionViewDelegate {
    func didSelectPhoto(at indexPath: IndexPath) {
        config?.onTapPhoto(indexPath.item)
    }
}

// MARK: - Private

private extension ReviewCell {
    
    func setupCell() {
        setupAvatarView()
        setupUsernameLabel()
        setupRatingView()
        setupReviewTextLabel()
        setupCollectionView()
        setupCreatedLabel()
        setupShowMoreButton()
    }
    
    func setupAvatarView() {
        contentView.addSubview(avatarView)
        avatarView.contentMode = .scaleAspectFit
        avatarView.layer.masksToBounds = true
        avatarView.layer.cornerRadius = Layout.avatarCornerRadius
    }
    
    func setupUsernameLabel() {
        contentView.addSubview(usernameLabel)
    }
    
    func setupRatingView() {
        contentView.addSubview(ratingView)
        ratingView.contentMode = .scaleAspectFit
    }
    
    func setupCollectionView() {
        contentView.addSubview(photosCollectionView)
        photosCollectionView.photosDelegate = self
    }
    
    func setupReviewTextLabel() {
        contentView.addSubview(reviewTextLabel)
        reviewTextLabel.lineBreakMode = .byWordWrapping
    }
    
    func setupCreatedLabel() {
        contentView.addSubview(createdLabel)
    }
    
    func setupShowMoreButton() {
        contentView.addSubview(showMoreButton)
        showMoreButton.contentVerticalAlignment = .fill
        showMoreButton.setAttributedTitle(Config.showMoreText, for: .normal)
        showMoreButton.addTarget(self, action: #selector(didTapShowMoreButton), for: .touchUpInside)
    }
    
    @objc
    func didTapShowMoreButton() {
        guard let config else { return }
        config.onTapShowMore(config.id)
    }
    
    
}

// MARK: - Layout

/// Класс, в котором происходит расчёт фреймов для сабвью ячейки отзыва.
/// После расчётов возвращается актуальная высота ячейки.
private final class ReviewCellLayout {
    
    // MARK: - Размеры
    
    fileprivate static let avatarSize = CGSize(width: 36.0, height: 36.0)
    fileprivate static let avatarCornerRadius = 18.0
    fileprivate static let photoCornerRadius = 8.0
    
    private static let photoSize = CGSize(width: 55.0, height: 66.0)
    private static let showMoreButtonSize = Config.showMoreText.size()
    
    // MARK: - Фреймы
    
    private(set) var avatarFrame = CGRect.zero
    private(set) var usernameLabelFrame = CGRect.zero
    private(set) var ratingFrame = CGRect.zero
    private(set) var photosCollectionViewFrame = CGRect.zero
    private(set) var reviewTextLabelFrame = CGRect.zero
    private(set) var showMoreButtonFrame = CGRect.zero
    private(set) var createdLabelFrame = CGRect.zero
    
    // MARK: - Отступы
    
    /// Отступы от краёв ячейки до её содержимого.
    private let insets = UIEdgeInsets(top: 9.0, left: 12.0, bottom: 9.0, right: 12.0)
    
    /// Горизонтальный отступ от аватара до имени пользователя.
    private let avatarToUsernameSpacing = 10.0
    /// Вертикальный отступ от имени пользователя до вью рейтинга.
    private let usernameToRatingSpacing = 6.0
    /// Вертикальный отступ от вью рейтинга до текста (если нет фото).
    private let ratingToTextSpacing = 6.0
    /// Вертикальный отступ от вью рейтинга до фото.
    private let ratingToPhotosSpacing = 10.0
    /// Горизонтальные отступы между фото.
    private let photosSpacing = 8.0
    /// Вертикальный отступ от фото (если они есть) до текста отзыва.
    private let photosToTextSpacing = 10.0
    /// Вертикальный отступ от текста отзыва до времени создания отзыва или кнопки "Показать полностью..." (если она есть).
    private let reviewTextToCreatedSpacing = 6.0
    /// Вертикальный отступ от кнопки "Показать полностью..." до времени создания отзыва.
    private let showMoreToCreatedSpacing = 6.0
    
    // MARK: - Расчёт фреймов и высоты ячейки
    
    /// Возвращает высоту ячейку с данной конфигурацией `config` и ограничением по ширине `maxWidth`.
    func height(config: Config, maxWidth: CGFloat) -> CGFloat {
        let width = maxWidth - insets.left - insets.right
        
        var maxY = insets.top
        
        avatarFrame = CGRect(
            origin: CGPoint(x: insets.left, y: insets.top),
            size: Self.avatarSize
        )
        
        let maxX = avatarFrame.maxX + avatarToUsernameSpacing
        
        usernameLabelFrame = CGRect(
            origin: CGPoint(x: maxX, y: maxY),
            size: config.fullName.boundingRect(width: width).size
        )
        
        maxY = usernameLabelFrame.maxY + usernameToRatingSpacing
        
        ratingFrame = CGRect(
            origin: CGPoint(x: maxX, y: maxY),
            size: config.ratingImage.size
        )
        
        maxY = ratingFrame.maxY + ratingToTextSpacing
        
        if let photoUrls = config.photoUrls, !photoUrls.isEmpty {
            let collectionWidth = width - maxX - insets.right
            let collectionHeight = Self.photoSize.height
            photosCollectionViewFrame = CGRect(
                x: maxX,
                y: maxY,
                width: collectionWidth,
                height: collectionHeight
            )
            maxY = photosCollectionViewFrame.maxY + photosToTextSpacing
        } else {
            photosCollectionViewFrame = .zero
        }
        
        var showShowMoreButton = false
        
        if !config.reviewText.isEmpty() {
            // Высота текста с текущим ограничением по количеству строк.
            let currentTextHeight = (config.reviewText.font()?.lineHeight ?? .zero) * CGFloat(config.maxLines)
            // Максимально возможная высота текста, если бы ограничения не было.
            let actualTextHeight = config.reviewText.boundingRect(width: width).size.height
            // Показываем кнопку "Показать полностью...", если максимально возможная высота текста больше текущей.
            showShowMoreButton = config.maxLines != .zero && actualTextHeight > currentTextHeight
            
            let reviewWidth = width - maxX - insets.right
            
            reviewTextLabelFrame = CGRect(
                origin: CGPoint(x: maxX, y: maxY),
                size: config.reviewText.boundingRect(width: reviewWidth, height: currentTextHeight).size
            )
            maxY = reviewTextLabelFrame.maxY + reviewTextToCreatedSpacing
        }
        
        if showShowMoreButton {
            showMoreButtonFrame = CGRect(
                origin: CGPoint(x: maxX, y: maxY),
                size: Self.showMoreButtonSize
            )
            maxY = showMoreButtonFrame.maxY + showMoreToCreatedSpacing
        } else {
            showMoreButtonFrame = .zero
        }
        
        createdLabelFrame = CGRect(
            origin: CGPoint(x: maxX, y: maxY),
            size: config.created.boundingRect(width: width).size
        )
        
        return createdLabelFrame.maxY + insets.bottom
    }
    
}

// MARK: - Typealias

fileprivate typealias Config = ReviewCellConfig
fileprivate typealias Layout = ReviewCellLayout

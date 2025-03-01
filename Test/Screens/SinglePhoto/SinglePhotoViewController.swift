//
//  SinglePhotoViewController.swift
//  Test
//
//  Created by Ilya Kuznetsov on 01.03.2025.
//

import UIKit

final class SinglePhotoViewController: UIViewController {
    
    // MARK: - Public Properties
    
    var viewModel: SinglePhotoViewModelProtocol
    var indexPath: IndexPath?
    
    var photo: UIImage? {
        didSet {
            guard isViewLoaded, let photo else { return }
            
            imageView.image = photo
            imageView.frame.size = photo.size
            rescaleAndCenterImageInScrollView(photo: photo)
        }
    }
    
    // MARK: - Private Properties
    
    private let imageProvider = ImageProvider.shared
    
    private lazy var activityIndicator: LoadingView = {
        let indicator = LoadingView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.indicatorStyle = .default
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.delegate = self
        
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = true
        scrollView.isScrollEnabled = true
        return scrollView
    }()
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .black
        return imageView
    }()
    
    private lazy var backButton: UIButton = {
        guard let buttonImage = UIImage(systemName: "chevron.backward") else { return UIButton() }
        let button = UIButton.systemButton(
            with: buttonImage,
            target: self,
            action: #selector(didTapBackButton)
        )
        button.tintColor = .systemBlue
        button.accessibilityIdentifier = "Back button"
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var shareButton: UIButton = {
        guard let buttonImage = UIImage(systemName: "square.and.arrow.up") else { return UIButton() }
        let button = UIButton(type: .custom)
        button.setImage(buttonImage, for: .normal)
        button.addTarget(self, action: #selector(didTapShareButton), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    init(viewModel: SinglePhotoViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSinglePhotoView()
        
        guard let photo else { return }
        
        imageView.image = photo
        imageView.frame.size = photo.size
        
        rescaleAndCenterImageInScrollView(photo: photo)
    }
    
    // MARK: - Actions
    
    @objc
    private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc
    private func didTapShareButton() {
        viewModel.sharePhoto(from: self)
    }
    
    
    // MARK: - Public Methods
    
    func setPhotoFromURL(
        fullImageStringURL: String
    ) {
        guard let url = URL(string: fullImageStringURL) else { return }
        viewModel.loadPhoto(from: url)
    }
    
    // MARK: - Private Methods
    
    private func setSinglePhotoView() {
        view.backgroundColor = .systemBackground
        view.addSubview(activityIndicator)
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        view.addSubview(backButton)
        view.addSubview(shareButton)
        
        NSLayoutConstraint.activate(
            backButtonConstraints() +
            shareButtonConstraints() +
            scrollViewConstraints() +
            activityIndicatorConstraints()
        )
        
        viewModel.onPhotoLoaded = { [weak self] image in
            guard let self = self, let image else { return }
            
            DispatchQueue.main.async {
                self.photo = image
                self.activityIndicator.isHidden = true
            }
        }
    }
    
    // MARK: - Constraints
    
    private func backButtonConstraints() -> [NSLayoutConstraint] {
        [
            backButton.leadingAnchor.constraint(equalTo:view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            backButton.topAnchor.constraint(equalTo:view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.widthAnchor.constraint(equalToConstant: 44),
            backButton.heightAnchor.constraint(equalToConstant: 44)
        ]
    }
    
    private func shareButtonConstraints() -> [NSLayoutConstraint] {
        [
            shareButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            shareButton.bottomAnchor.constraint(equalTo:view.safeAreaLayoutGuide.bottomAnchor, constant: -17),
            shareButton.widthAnchor.constraint(equalToConstant: 44),
            shareButton.heightAnchor.constraint(equalToConstant: 44)
        ]
    }
    
    private func scrollViewConstraints() -> [NSLayoutConstraint] {
        [
            scrollView.leadingAnchor.constraint(equalTo:view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo:view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ]
    }
    
    private func activityIndicatorConstraints() -> [NSLayoutConstraint] {
        [
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ]
    }
    
    private func rescaleAndCenterImageInScrollView(photo: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        let imageSize = photo.size
        let hScale =   visibleRectSize.width / imageSize.width
        let vScale =  visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, max(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    private func centerImage() {
        var insets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        let visibleRectSize = scrollView.bounds.size
        let newContentSize = scrollView.contentSize
        if visibleRectSize.width > newContentSize.width {
            insets.left = visibleRectSize.width / 2
            insets.right = visibleRectSize.width / 2
        }
        if visibleRectSize.height > newContentSize.height {
            insets.top = visibleRectSize.height / 2
            insets.bottom = visibleRectSize.height / 2
        }
        scrollView.contentInset = insets
    }
}

// MARK: - Extensions

// MARK: UIScrollViewDelegate

extension SinglePhotoViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImage()
    }
}

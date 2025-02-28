//
//  SinglePhotoViewModel.swift
//  Test
//
//  Created by Ilya Kuznetsov on 01.03.2025.
//

import UIKit

protocol SinglePhotoViewModelProtocol {
    var photo: UIImage? { get }
    var isLoading: Bool { get }
    
    func loadPhoto(from url: URL)
    func sharePhoto(from viewController: UIViewController?)
}

final class SinglePhotoViewModel: SinglePhotoViewModelProtocol {
    // MARK: - Properties
    
    private let imageProvider: ImageProvider
    private(set) var photo: UIImage? = nil
    private(set) var isLoading: Bool = false
    
    // MARK: - Initialization
    
    init(imageProvider: ImageProvider = ImageProvider.shared) {
        self.imageProvider = imageProvider
    }
    
    // MARK: - Public Methods
    
    func loadPhoto(from url: URL) {
        isLoading = true
        
        imageProvider.loadImage(from: url, targetSize: CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)) { [weak self] image in
            self?.photo = image
            self?.isLoading = false
        }
    }
    
    func sharePhoto(from viewController: UIViewController?) {
        guard let photo = photo, let viewController = viewController else { return }
        let activityController = UIActivityViewController(activityItems: [photo], applicationActivities: nil)
        viewController.present(activityController, animated: true)
    }
}

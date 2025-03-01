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
    
    var onPhotoLoaded: ((UIImage?) -> Void)? { get set }
    
    func loadPhoto(from url: URL)
    func sharePhoto(from viewController: UIViewController?)
}

final class SinglePhotoViewModel: SinglePhotoViewModelProtocol {
    
    // MARK: - Properties
    
    var onPhotoLoaded: ((UIImage?) -> Void)?
    
    private let imageProvider: ImageProvider
    private(set) var photo: UIImage? = nil {
        didSet {
            onPhotoLoaded?(photo)
        }
    }
    private(set) var isLoading: Bool = false
    
    // MARK: - Initialization
    
    init(imageProvider: ImageProvider = ImageProvider.shared) {
        self.imageProvider = imageProvider
    }
    
    // MARK: - Public Methods
    
    func loadPhoto(from url: URL) {
        isLoading = true
        
        imageProvider.loadFullImage(from: url) { [weak self] image in
            self?.photo = image
            self?.isLoading = false
            
        }
    }
    
    func sharePhoto(from viewController: UIViewController?) {
        
        guard let photo = photo, let viewController = viewController else {
            print("Photo or ViewController is nil")
            return
        }
        
        let activityController = UIActivityViewController(activityItems: [photo], applicationActivities: nil)
        viewController.present(activityController, animated: true)
    }
}

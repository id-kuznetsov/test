//
//  PhotoCell.swift
//  Test
//
//  Created by Ilya Kuznetsov on 27.02.2025.
//

import UIKit

final class PhotoCell: UICollectionViewCell {
    
    // MARK: - Public Properties
    
    static let reuseIdentifier = "PhotoCell"
    
    // MARK: - Private Properties
    
    private let imageProvider = ImageProvider.shared
    
    private lazy var photoImageView: UIImageView = {
        let photoImageView = UIImageView()
        photoImageView.layer.cornerRadius = 8
        photoImageView.layer.masksToBounds = true
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        return photoImageView
    }()
    
    private lazy var activityIndicator: LoadingView = {
        let indicator = LoadingView(radius: 10)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()
    
    // MARK: - Initialisers
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setCellUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        photoImageView.image = nil
    }
    
    // MARK: - Public Methods
    
    func configureCell(photoUrl: String) {
        activityIndicator.isHidden = false
        if let photoUrl = URL(string: photoUrl) {
            imageProvider.loadImage(from: photoUrl, targetSize: CGSize(width: 55.0, height: 66.0)) { [weak self] image in
                self?.photoImageView.image = image
                self?.activityIndicator.isHidden = true
            }
        }
    }
    
    // MARK: - Private Methods
    private func setCellUI() {
        contentView.addSubview(photoImageView)
        contentView.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate(
            [
                photoImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                photoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                photoImageView.widthAnchor.constraint(equalToConstant: 55),
                photoImageView.heightAnchor.constraint(equalToConstant: 66),
                
                activityIndicator.centerXAnchor.constraint(equalTo: photoImageView.centerXAnchor),
                activityIndicator.centerYAnchor.constraint(equalTo: photoImageView.centerYAnchor),
                activityIndicator.widthAnchor.constraint(equalToConstant: 20),
                activityIndicator.heightAnchor.constraint(equalToConstant: 20)
            ]
        )
    }
}


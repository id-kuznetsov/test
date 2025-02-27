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
        if let photoUrl = URL(string: photoUrl) {
            imageProvider.loadImage(from: photoUrl) { [weak self] image in
                self?.photoImageView.image = image
            }
        }
    }
    
    // MARK: - Private Methods
    private func setCellUI() {
        contentView.addSubview(photoImageView)
        
        NSLayoutConstraint.activate(
            [
                photoImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
                photoImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
                photoImageView.widthAnchor.constraint(equalToConstant: 55),
                photoImageView.heightAnchor.constraint(equalToConstant: 66)
            ]
        )
    }
}


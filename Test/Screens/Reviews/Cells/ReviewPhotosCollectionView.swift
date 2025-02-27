//
//  ReviewPhotosCollectionView.swift
//  Test
//
//  Created by Ilya Kuznetsov on 26.02.2025.
//

import UIKit

final class ReviewPhotosCollectionView: UICollectionView {
    
    // MARK: - Private Properties
    
    private var photoUrls: [String]?
    
    // MARK: - Initialisers
    
    init() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 8
        layout.itemSize = CGSize(width: 55.0, height: 66.0)
        
        super.init(frame: .zero, collectionViewLayout: layout)
        
        dataSource = self
        delegate = self
        register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.reuseIdentifier)
        showsHorizontalScrollIndicator = false
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Methods
    
    func setPhotos(_ urls: [String]?) {
        photoUrls = urls
        reloadData()
    }

}

// MARK: - Extensions
// MARK:  UICollectionViewDataSource & UICollectionViewDelegate
extension ReviewPhotosCollectionView: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        photoUrls?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: PhotoCell.reuseIdentifier,
            for: indexPath
        ) as? PhotoCell else {
            return UICollectionViewCell()
        }
        guard let photoUrls = photoUrls else {
            return cell
        }
        cell.configureCell(photoUrl: photoUrls[indexPath.item])
        // TODO: метод настройки ячейки
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selected item at indexPath: \(indexPath.item)")
    }
}

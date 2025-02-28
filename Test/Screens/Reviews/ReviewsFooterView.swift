//
//  ReviewsFooterView.swift
//  Test
//
//  Created by Ilya Kuznetsov on 28.02.2025.
//

import UIKit

final class ReviewsFooterView: UIView {
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.font = .reviewCount
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateText(reviewsCount: Int) {
        titleLabel.text = String.localizedStringWithFormat(
            NSLocalizedString("%d reviews", comment: "Количество отзывов"),
            reviewsCount
        )
    }
    
    private func setupView() {
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

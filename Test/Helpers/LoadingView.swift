//
//  LoadingView.swift
//  Test
//
//  Created by Ilya Kuznetsov on 28.02.2025.
//

import UIKit

final class LoadingView: UIView {
    
    private let dotCount = 7
    private let dotColor = UIColor.systemBlue.cgColor
    private var radius: CGFloat = 20
    private var dotSize: CGFloat = 10
    private var dotLayers: [CALayer] = []
    
    convenience init(radius: CGFloat) {
        self.init(frame: .zero)
        self.radius = radius
        self.dotSize = radius * 0.01
        setupDots()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupDots()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupDots()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateDotPositions()
    }
    
    private func setupDots() {
        for _ in 0..<dotCount {
            let dotLayer = CALayer()
            dotLayer.frame = CGRect(x: 0, y: 0, width: dotSize, height: dotSize)
            dotLayer.cornerRadius = dotSize / 2
            dotLayer.backgroundColor = dotColor
            layer.addSublayer(dotLayer)
            dotLayers.append(dotLayer)
        }
    }
    
    private func updateDotPositions() {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        for (index, dotLayer) in dotLayers.enumerated() {
            let angle = CGFloat(index) * (2 * .pi / CGFloat(dotCount))
            let x = center.x + radius * cos(angle)
            let y = center.y + radius * sin(angle)
            dotLayer.position = CGPoint(x: x, y: y)
        }
        startAnimation()
    }
    
    private func startAnimation() {
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.path = circularPath().cgPath
        animation.duration = 3
        animation.repeatCount = .infinity
        animation.calculationMode = .paced
        
        for (index, dotLayer) in dotLayers.enumerated() {
            guard let animCopy = animation.copy() as? CAKeyframeAnimation else { continue }
            animCopy.timeOffset = CFTimeInterval(index) * (animation.duration / Double(dotCount))
            dotLayer.add(animCopy, forKey: "orbit")
            dotLayer.speed = 1.5
        }
    }
    
    private func circularPath() -> UIBezierPath {
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        return UIBezierPath(arcCenter: center, radius: radius, startAngle: 0, endAngle: 2 * .pi, clockwise: true)
    }
}


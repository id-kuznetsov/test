//
//  ImageProvider.swift
//  Test
//
//  Created by Ilya Kuznetsov on 26.02.2025.
//

import UIKit

final class ImageProvider {
    
    static let shared = ImageProvider()

    private let cache = Cache<URL, UIImage>(entryLifetime: 600)
    
    private init() {}
    
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = cache.value(forKey: url) {
            completion(cachedImage)
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let self, let data, error == nil, let image = UIImage(data: data) else {
                DispatchQueue.main.async { completion(nil) }
                return
            }

            self.cache.insert(image, forKey: url)
            
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
}

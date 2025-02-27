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
    private let queue = DispatchQueue(label: "ImageProviderQueue")
    
    private init() {}
    
    func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = cache.value(forKey: url) {
            completion(cachedImage)
            return
        }
        
        queue.async { [weak self] in
            guard let self else { return }
            
            let imageTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                guard let self, let data, error == nil, let image = UIImage(data: data) else {
                    DispatchQueue.main.async { completion(nil) }
                    return
                }
                
                if let compressedData = image.jpegData(compressionQuality: 0.1),
                   let compressedImage = UIImage(data: compressedData) {
                    self.cache.insert(compressedImage, forKey: url)
                    
                    DispatchQueue.main.async {
                        completion(compressedImage)
                    }
                } else {
                    DispatchQueue.main.async {
                        completion(image)
                    }
                }
            }
            
            imageTask.resume()
        }
    }
}

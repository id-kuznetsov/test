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
    private let queue = DispatchQueue(label: "ImageProviderQueue", attributes: .concurrent)
    
    private init() {}

    func loadImage(from url: URL, targetSize: CGSize, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = cache.value(forKey: url) {
            completion(cachedImage)
            return
        }

        queue.async { [weak self] in
            guard let self else { return }

            let imageTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                guard let self, let data, error == nil,
                      let downsampledImage = self.downsample(data: data, to: targetSize) else {
                    DispatchQueue.main.async { completion(nil) }
                    return
                }

                self.cache.insert(downsampledImage, forKey: url)

                DispatchQueue.main.async {
                    completion(downsampledImage)
                }
            }

            imageTask.resume()
        }
    }

    private func downsample(data: Data, to pointSize: CGSize, scale: CGFloat = UIScreen.main.scale) -> UIImage? {
        let imageSourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, imageSourceOptions) else {
            return nil
        }

        let maxDimensionInPixels = max(pointSize.width, pointSize.height) * scale

        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxDimensionInPixels
        ] as CFDictionary

        guard let downsampledImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, downsampleOptions) else {
            return nil
        }

        return UIImage(cgImage: downsampledImage)
    }
}


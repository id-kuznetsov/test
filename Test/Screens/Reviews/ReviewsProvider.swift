import Foundation

/// Класс для загрузки отзывов.
final class ReviewsProvider {
    
    private let bundle: Bundle
    private let queue = DispatchQueue(label: "ReviewsProviderQueue")
    private let mainQueue = DispatchQueue.main
    
    init(bundle: Bundle = .main) {
        self.bundle = bundle
    }
    
}

// MARK: - Internal

extension ReviewsProvider {
    
    typealias GetReviewsResult = Result<Data, GetReviewsError>
    
    enum GetReviewsError: Error {
        
        case badURL
        case badData(Error)
        
    }
    
    func getReviews(offset: Int = 0, completion: @escaping (GetReviewsResult) -> Void) {
        guard let url = bundle.url(forResource: "getReviews.response", withExtension: "json") else {
            return completion(.failure(.badURL))
        }
        
        queue.async { [weak self] in
            usleep(.random(in: 100_000...1_000_000)) // Симуляция сети
            
            do {
                let data = try Data(contentsOf: url)
                self?.mainQueue.async {
                    completion(.success(data))
                }
            } catch {
                self?.mainQueue.async {
                    completion(.failure(.badData(error)))
                }
            }
        }
    }
}

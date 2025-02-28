import Foundation

/// Класс для загрузки отзывов.
final class ReviewsProvider {
    
    private let bundle: Bundle
    private let queue = DispatchQueue(label: "ReviewsProviderQueue")
    private let mainQueue = DispatchQueue.main
    
    private var isFetching = false
    
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
        case alreadyFetching
        
    }
    
    func getReviews(offset: Int = 0, completion: @escaping (GetReviewsResult) -> Void) {
        guard !isFetching else {
               return completion(.failure(.alreadyFetching))
           }
        
        isFetching = true
        
        guard let url = bundle.url(forResource: "getReviews.response", withExtension: "json") else {
            isFetching = false
            return completion(.failure(.badURL))
        }
        
        queue.async { [weak self] in
            usleep(.random(in: 100_000...1_000_000)) // Симуляция сети
            
            do {
                let data = try Data(contentsOf: url)
                self?.mainQueue.async {
                    self?.isFetching = false
                    completion(.success(data))
                }
            } catch {
                self?.mainQueue.async {
                    self?.isFetching = false 
                    completion(.failure(.badData(error)))
                }
            }
        }
    }
}

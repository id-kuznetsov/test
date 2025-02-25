/// Модель отзыва.
struct Review: Decodable {

    let firstName: String
    let lastName: String
    let rating: Int
    let text: String
    let created: String
    
    var fullName: String {
        "\(firstName) \(lastName)"
    }
    // TODO: add photo
}

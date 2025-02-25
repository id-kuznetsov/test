/// Модель отзыва.
struct Review: Decodable {

    let firstName: String
    let lastName: String
    let rating: Int
    let text: String
    let created: String
    // TODO: add photo
}

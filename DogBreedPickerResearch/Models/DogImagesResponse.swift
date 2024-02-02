import Foundation

struct DogImagesResponse: Codable {
    let message: [String]
    let status: String
}

struct BreedListResponse: Codable {
    let message: [String: [String]]
}

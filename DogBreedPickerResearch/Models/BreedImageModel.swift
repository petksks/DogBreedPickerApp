import UIKit

class ImageCache {
    static let shared = NSCache<NSString, UIImage>()
    private init() {}
}

struct BreedImageModel {
    func fetchImageURLs(forBreed breed: String, completion: @escaping ([String]?, Error?) -> Void) {
        let urlString = "https://dog.ceo/api/breed/\(breed)/images"
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "Invalid URL", code: -1, userInfo: nil))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let data = data,
                  let response = try? JSONDecoder().decode(DogImagesResponse.self, from: data) else {
                completion(nil, NSError(domain: "Invalid Data", code: -1, userInfo: nil))
                return
            }

            completion(response.message, nil)
        }.resume()
    }

    func fetchImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = ImageCache.shared.object(forKey: urlString as NSString) {
            completion(cachedImage)
            return
        }

        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            ImageCache.shared.setObject(image, forKey: urlString as NSString)
            completion(image)
        }.resume()
    }
}

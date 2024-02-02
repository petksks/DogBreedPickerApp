import Foundation

class BreedListManager {
    func fetchBreedList(completion: @escaping ([String]?, Error?) -> Void) {
        guard let url = URL(string: "https://dog.ceo/api/breeds/list/all") else {
            completion(nil, NSError(domain: "InvalidURL", code: 0, userInfo: nil))
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }

            guard let data = data else {
                completion(nil, NSError(domain: "NoData", code: 0, userInfo: nil))
                return
            }

            do {
                let decodedResponse = try JSONDecoder().decode(BreedListResponse.self, from: data)
                let breeds = decodedResponse.message.keys.sorted()
                completion(breeds, nil)
            } catch {
                completion(nil, error)
            }
        }

        task.resume()
    }
}

//// Helper struct to decode the JSON response
//struct BreedListResponse: Codable {
//    let message: [String: [String]]
//}

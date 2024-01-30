import Foundation

class FavoriteManager {
    
    // MARK: - Singleton
    static let shared = FavoriteManager()
    
    private let favoritesKey = "favoriteImages"
        
    // Get and set favorite images from UserDefaults
    private var favoriteImages: [FavoriteImage] {
        get {
            if let data = UserDefaults.standard.data(forKey: favoritesKey) {
                do {
                    return try JSONDecoder().decode([FavoriteImage].self, from: data)
                } catch {
                    print("Error decoding favorite images: \(error)")
                    return []
                }
            } else {
                return []
            }
        }
        set {
            do {
                let data = try JSONEncoder().encode(newValue)
                UserDefaults.standard.set(data, forKey: favoritesKey)
            } catch {
                print("Error encoding favorite images: \(error)")
            }
        }
    }
    
    // MARK: - Public Methods
    
    // Add a new favorite image
    func addFavorite(imageUrl: String, breed: String, completion: @escaping (Bool) -> Void) {
        let newFavorite = FavoriteImage(imageUrl: imageUrl, breed: breed)
        var favorites = favoriteImages
        favorites.append(newFavorite)
        favoriteImages = favorites
        completion(true)
    }
    
    // Get all favorite images
    func getFavorites() -> [FavoriteImage] {
        return favoriteImages
    }
    
    // Remove a favorite image
    func removeFavorite(imageUrl: String, completion: @escaping (Bool) -> Void) {
        let favorites = favoriteImages.filter { $0.imageUrl != imageUrl }
        favoriteImages = favorites
        completion(true)
    }
    
    // Check if an image is a favorite
    func isFavorite(imageUrl: String) -> Bool {
        return favoriteImages.contains { $0.imageUrl == imageUrl }
    }
}

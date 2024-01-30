import UIKit

class ImageDetailController: UIViewController, UIScrollViewDelegate {

    var imageURL: String?
    var image: UIImage?
    var breed: String?

    private let imageDetailView = ImageDetailView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = breed
        setupUI()
    }

    private func setupUI() {
        setupNavigationBarButton()
        setupImageDetailView()
    }

    private func setupNavigationBarButton() {
        guard let imageURL = imageURL else { return }
        let isFavourite = FavoriteManager.shared.isFavorite(imageUrl: imageURL)
        let icon = isFavourite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        let favoriteButton = UIBarButtonItem(image: icon, style: .plain, target: self, action: #selector(favoriteButtonTapped))
        navigationItem.rightBarButtonItem = favoriteButton
    }

    @objc private func favoriteButtonTapped() {
        guard let imageURL = imageURL else { return }
        let isFavourite = FavoriteManager.shared.isFavorite(imageUrl: imageURL)
        if isFavourite {
            removeImageFromFavourite(with: imageURL)
        } else {
            addImageToFavourite(with: imageURL)
        }
    }

    private func addImageToFavourite(with url: String) {
        FavoriteManager.shared.addFavorite(imageUrl: url, breed: breed ?? "", completion: { [weak self] success in
            guard let self = self else { return }
            self.presentSuccessPopupView(title: "Add to favorites", message: "Images has been added to favorites successfully!")
        })
    }

    private func removeImageFromFavourite(with url: String) {
        guard let imageURL = imageURL else { return }
        FavoriteManager.shared.removeFavorite(imageUrl: imageURL) { [weak self] success in
            guard let self = self else { return }
            self.presentSuccessPopupView(title: "Removed from favorites", message: "Image has been removed from favorites!")
        }
    }

    private func setupImageDetailView() {
        imageDetailView.frame = view.bounds
        view.addSubview(imageDetailView)
        if let image = image {
            imageDetailView.display(images: image)
        }
    }

    private func presentSuccessPopupView(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true) { [weak self] in
            self?.updateNavigationBarButtonIcon()
        }
    }

    private func updateNavigationBarButtonIcon() {
        guard let imageURL = imageURL, let rightBarButton = navigationItem.rightBarButtonItem else { return }
        let isFavourite = FavoriteManager.shared.isFavorite(imageUrl: imageURL)
        let icon = isFavourite ? UIImage(systemName: "heart.fill") : UIImage(systemName: "heart")
        rightBarButton.image = icon
    }
}


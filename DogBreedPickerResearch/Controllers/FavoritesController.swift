import UIKit

class FavoritesController: UIViewController {
    
    private var favoriteImages: [FavoriteImage] = []
    private var images: [UIImage] = []
    
    private let breedImagesView = FavoriteImageView()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, UIImage>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Favorites"
        setupCollectionView()
        configureDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.favoriteImages = []
        self.images = []
        fetchImages()
    }
    
    private func setupCollectionView() {
        view.addSubview(breedImagesView)
        breedImagesView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            breedImagesView.topAnchor.constraint(equalTo: view.topAnchor),
            breedImagesView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            breedImagesView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            breedImagesView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        breedImagesView.collectionView.delegate = self
    }
    
    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, UIImage>(collectionView: breedImagesView.collectionView) { (collectionView, indexPath, image) -> UICollectionViewCell? in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.identifier, for: indexPath) as! ImageCell
            cell.configure(with: image)
            return cell
        }
        breedImagesView.collectionView.register(ImageCell.self, forCellWithReuseIdentifier: ImageCell.identifier)
    }
    
    private func fetchImages() {
        self.favoriteImages = FavoriteManager.shared.getFavorites()
        
        for image in favoriteImages {
            self.fetchImage(from: image.imageUrl) { image in
                guard let image = image else { return }
                self.images.append(image)
                self.updateCollectionView()
            }
        }
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
    
    private func updateCollectionView() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, UIImage>()
        snapshot.appendSections([.main])
        snapshot.appendItems(images)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension FavoritesController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let detailsViewController = ImageDetailController()
        detailsViewController.imageURL = favoriteImages[indexPath.row].imageUrl
        detailsViewController.image = images[indexPath.row]
        detailsViewController.breed = favoriteImages[indexPath.row].breed
        navigationController?.pushViewController(detailsViewController, animated: true)
    }
}

extension FavoritesController {
    enum Section {
        case main
    }
}

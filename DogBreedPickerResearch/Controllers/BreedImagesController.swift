import UIKit

class BreedImagesController: UIViewController {
    
    var breed: String?
    
    private let breedImageModel = BreedImageManager()
    private var images: [UIImage] = []
    private var urls: [String] = []
    private let breedImagesView = BreedImagesView()
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, UIImage>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = breed?.capitalized
        setupCollectionView()
        configureDataSource()
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
        guard let breedName = breed else { return }
        breedImageModel.fetchImageURLs(forBreed: breedName) { [weak self] urls, error in
            guard let self = self, let urls = urls, error == nil else {
                return
            }
            
            self.urls = urls
            
            for url in urls {
                self.breedImageModel.fetchImage(from: url) { image in
                    guard let image = image else { return }
                    self.images.append(image)
                    self.updateCollectionView()
                }
            }
        }
    }
    
    private func updateCollectionView() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, UIImage>()
        snapshot.appendSections([.main])
        snapshot.appendItems(images)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - UICollectionViewDelegate
extension BreedImagesController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedImage = images[indexPath.row]
        let detailsViewController = ImageDetailController()
        detailsViewController.imageURL = urls[indexPath.row]
        detailsViewController.image = images[indexPath.row]
        detailsViewController.breed = breed
        navigationController?.pushViewController(detailsViewController, animated: true)
    }
}

// MARK: - Section Definition
extension BreedImagesController {
    enum Section {
        case main
    }
}

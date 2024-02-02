import UIKit

class HomeController: UIViewController {
    private let breedListAPI = BreedListManager()
    private var breeds: [String] = []
    private let breedListView = BreedListView()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Breeds List"
        navigationController?.navigationBar.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 40)]
        
        setupBreedListView()
        fetchBreeds()
        
        // Create a "Favorites" button in the navigation bar.
        let favoriteButton = UIBarButtonItem(image: UIImage(systemName: "heart"), style: .plain, target: self, action: #selector(favoriteButtonTapped))
        navigationItem.rightBarButtonItem = favoriteButton
    }
    
    @objc private func favoriteButtonTapped() {
        let favouriteController = FavoritesController()
        self.navigationController?.pushViewController(favouriteController, animated: true)
    }

    private func setupBreedListView() {
        view.addSubview(breedListView)
        breedListView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            breedListView.topAnchor.constraint(equalTo: view.topAnchor),
            breedListView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            breedListView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            breedListView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        breedListView.tableView.dataSource = self
        breedListView.tableView.delegate = self
    }

    private func fetchBreeds() {
        // Fetch the list of dog breeds using the breedListAPI.
        breedListAPI.fetchBreedList { [weak self] breeds, error in
            DispatchQueue.main.async {
                if let breeds = breeds {
                    self?.breeds = breeds
                    self?.breedListView.tableView.reloadData()
                } else if let error = error {
                    print("Error fetching breeds: \(error)")
                }
            }
        }
    }
}

extension HomeController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Return the number of dog breeds to be displayed in the table view.
        return breeds.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Configure and return a cell for displaying a dog breed in the table view.
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DogCellView.identifier, for: indexPath) as? DogCellView else {
            fatalError("Unable to dequeue DogCell")
        }
        cell.selectionStyle = .none
        cell.configure(with: breeds[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // When a row (dog breed) is selected, navigate to the BreedImagesController for that breed.
        let selectedBreed = breeds[indexPath.row]
        let breedImagesVC = BreedImagesController()
        breedImagesVC.breed = selectedBreed
        navigationController?.pushViewController(breedImagesVC, animated: true)
    }
}

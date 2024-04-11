import UIKit


class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    // ACTIONS
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    // PROPERTIES
    
    var movies = [Movie]()
    let movieService = MovieService()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self // Configura este ViewController como el delegado de la searchBar
        
    }
    

    func fetchMovies(searchTerm: String) {
        movieService.fetchMovies(searchTerm: searchTerm) { [weak self] (movies: [Movie]?) in
            guard let movies = movies else { return }
            self?.movies = movies
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? MovieTableViewCell else {
            fatalError("Unable to dequeue MovieTableViewCell")
        }
        let movie = movies[indexPath.row]
        cell.configure(with: movie)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Aquí puedes manejar la selección de una película para mostrar más detalles
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count >= 3 { // Considera buscar solo si el usuario ha escrito 3 o más caracteres
            fetchMovies(searchTerm: searchText)
        }
    }
}

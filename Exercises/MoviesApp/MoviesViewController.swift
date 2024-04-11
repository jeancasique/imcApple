import UIKit


class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    // ACTIONS
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var imagenBack: UIImageView!
    
    // PROPERTIES
    
    var movies = [Movie]()
    let movieService = MovieService()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        searchBar.becomeFirstResponder()
        tableView.isHidden = true
        imagenBack.isHidden = false
        NotificationCenter.default.addObserver(self, selector: #selector(favoriteStatusDidChange), name: NSNotification.Name("FavoriteStatusChanged"), object: nil)
    }
    
    //METODOS
    
    func fetchMovies(searchTerm: String) {
            movieService.fetchMovies(searchTerm: searchTerm) { [weak self] (movies: [Movie]?) in
                guard let movies = movies else { return }
                self?.movies = movies
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {  // Define el número de filas en la sección del tableView, igual al número de películas.
        return movies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { // Proporciona la celda a mostrar para cada fila del tableView.
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? MovieTableViewCell else { // Intenta reutilizar una celda existente o crea una nueva si es necesario.
            fatalError("Unable to dequeue MovieTableViewCell")
        }
        let movie = movies[indexPath.row] // Obtiene la película para la fila actual.
         cell.configure(with: movie)  // Configura la celda con los datos de la película.
           return cell  // Devuelve la celda configurada para mostrarla en el tableView.
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Aquí puedes manejar la selección de una película para mostrar más detalles
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.count >= 3 {
            //  buscar solo si el usuario ha escrito 3 o más caracteres
            fetchMovies(searchTerm: searchText)
            tableView.isHidden = false
            imagenBack.isHidden = true
        } else if searchText.isEmpty {
            // Si el campo de texto está vacío, muestra la imagen de fondo y oculta la tabla
            tableView.isHidden = true
            imagenBack.isHidden = false
        }
    }
    @objc func favoriteStatusDidChange(notification: NSNotification) {
        //  recargar los datos del tableView
        tableView.reloadData()
    }
    deinit {
        //Destruye el notification para evitar referencias colgadas o llamadas a un objeto ya liberado
        NotificationCenter.default.removeObserver(self)
    }
    
    //SEGUE
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailMovieSegue",// Verifica que el segue "DetailMovieSegue" sea el del identificador.
           let destinationVC = segue.destination as? DetailViewController, // Intenta obtener el ViewController de destino como DetailViewController para asegurar que el tipo coincide.
            let indexPath = tableView.indexPathForSelectedRow {  // Obtiene el índice de la fila seleccionada en la tabla. Esto es necesario para saber qué película se ha seleccionado.
             let selectedMovie = movies[indexPath.row]   // Utiliza el índice para obtener la película específica seleccionada de la lista de películas.
               destinationVC.movie = selectedMovie  // Asigna la película seleccionada al ViewController de destino para que pueda usarla para mostrar detalles específicos.
        }
    }
}

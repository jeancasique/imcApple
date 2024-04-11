
import UIKit


class DetailViewController: UIViewController {
    
    // ACTIONS
    
    @IBOutlet weak var DetailImagen: UIImageView!
    
    @IBOutlet weak var DetailTitle: UILabel!
    
    @IBOutlet weak var DetailYear: UILabel!
    
    @IBOutlet weak var DetailDescription: UILabel!
    
    @IBOutlet weak var DetailDirector: UILabel!
    
    @IBOutlet weak var DetailCountry: UILabel!
    
    @IBOutlet weak var DetailGenre: UILabel!
    
    @IBOutlet weak var favoriteButton: UIBarButtonItem!
    
    // PROPERTIES
    
     var movie: Movie? = nil
     let movieService = MovieService()
    
    override func viewDidLoad() {
            super.viewDidLoad()
            if let movie = movie {
                updateUIWithMovie(movie)
                   if movie.plot == nil || movie.director == nil || movie.country == nil {
                    loadMovieDetails()
                      updateFavoriteStatus()
                }
            }
        }
    
    //METODOS
    
        func updateUIWithMovie(_ movie: Movie) {
            DetailImagen.loadDetailImage(fromURL: movie.poster)
            DetailTitle.text = movie.title
            DetailYear.text = "Año: \(movie.year)"
            DetailDescription.text = "Descripción: \(movie.plot ?? "Descripción no disponible")"
            DetailDirector.text = "Directores: \(movie.director ?? "Director no Disponible")"
            DetailCountry.text = "Pais: \(movie.country ?? "Pais no Disponible")"
            DetailGenre.text = "Genero: \(movie.genre ?? "genre not available")" }
    
       func updateFavoriteStatus() {
           guard let movie = movie else { return }
           
             let isFavorite = UserDefaults.standard.bool(forKey: movie.imdbID)
           
              let imageName = isFavorite ? "suit.heart.fill" : "suit.heart"
           
                favoriteButton.image = UIImage(systemName: imageName)  }
    
      @IBAction func favoriteButtonTapped(_ sender: UIBarButtonItem) {
           guard let movie = movie else { return }
               
             let isFavorite = !UserDefaults.standard.bool(forKey: movie.imdbID) // Actualiza el estado de favorito de la película en UserDefaults
          
                UserDefaults.standard.set(isFavorite, forKey: movie.imdbID)// Actualiza el estado de favorito de la película en UserDefaults. Si 'isFavorite' es 'true', la película se marca como favorita; si es 'false', se desmarca.
          
                 let imageName = isFavorite ? "suit.heart.fill" : "suit.heart" // Elige el nombre de la imagen a mostrar en el botón basado en si la película es ahora favorita o no. Si 'isFavorite' es 'true', se usa la imagen de corazón lleno; si es 'false', se usa la imagen de corazón vacío.
          
                   favoriteButton.image = UIImage(systemName: imageName)// Actualiza la imagen del botón de favorito en la barra de navegación con la imagen correspondiente al estado de favorito actual de la película.
          
                     NotificationCenter.default.post(name: NSNotification.Name("FavoriteStatusChanged"), object: nil) // Envía una notificación a través del NotificationCenter indicando que el estado de favorito de alguna película ha cambiado. Esto permite que otras partes de la aplicación que estén escuchando esta notificación puedan responder adecuadamente, como actualizando una lista de películas favoritas.
        }
    
        func loadMovieDetails() {
            guard let imdbID = movie?.imdbID else { return }
            
              movieService.fetchMovieDetails(imdbID: imdbID) { [weak self] detailedMovie in
                DispatchQueue.main.async {
                    if let detailedMovie = detailedMovie {
                        self?.updateUIWithMovie(detailedMovie)
                    }
                }
            }
        }
    }

      extension UIImageView {
         func loadDetailImage(fromURL urlString: String) {
            guard let encodedURLString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: encodedURLString) else {
            print("Invalid URL")
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            DispatchQueue.main.async {
                self.image = UIImage(data: data)
            }
        }.resume()
    }
}

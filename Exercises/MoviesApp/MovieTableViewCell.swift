
import UIKit
class MovieTableViewCell: UITableViewCell {
    
    //PROPERTIES
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subTitleLabel: UILabel!
    @IBOutlet var movieImageView: UIImageView!
    @IBOutlet var favoriteButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
      
    }
    
   //METODOS
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    func configure(with movie: Movie) { // Función para configurar la celda
        titleLabel.text = movie.title
        subTitleLabel.text = movie.year
        movieImageView.loadImage(fromURL: movie.poster)
        
         let isFavorite = UserDefaults.standard.bool(forKey: movie.imdbID) // Verifica si la película actual es favorita según UserDefaults y ajusta la visibilidad del botón de favoritos usando el ID de la película
           favoriteButton.isHidden = !isFavorite // Oculta el botón si la película no es favorita.
    }
}
extension UIImageView {  // Carga una imagen desde una URL y la establece como la imagen de este UIImageView.
    func loadImage(fromURL urlString: String) {
        guard let url = URL(string: urlString) else { return } // Asegura que la URL es válida.
        URLSession.shared.dataTask(with: url) { data, response, error in  // Inicia una tarea de red para descargar la imagen
            guard let data = data, error == nil else { return } // Verifica que se recibieron datos y no hubo errores
            DispatchQueue.main.async {  // Asegura que la actualización de la UI se ejecute en el hilo principal
                self.image = UIImage(data: data) // Crea una imagen a partir de los datos recibidos y la asigna al UIImageView
            }
        }.resume()  // Inicia la tarea de red
    }
}


import UIKit
class MovieTableViewCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var subTitleLabel: UILabel!
    @IBOutlet var movieImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    // Función para configurar la celda
    func configure(with movie: Movie) {
        titleLabel.text = movie.title
        subTitleLabel.text = movie.year
  
        movieImageView.loadImage(fromURL: movie.poster) 
    }
    
}
extension UIImageView {
    func loadImage(fromURL urlString: String) {
        guard let url = URL(string: urlString) else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async {
                self.image = UIImage(data: data)
            }
        }.resume()
    }
}

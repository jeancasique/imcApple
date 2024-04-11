import Foundation

class MovieService {
    private let apiKey = "fde4bf0f"
    private let baseURL = URL(string: "https://www.omdbapi.com/")!
    
    func fetchMovies(searchTerm: String, completion: @escaping ([Movie]?) -> Void) {
        let queryItems = [URLQueryItem(name: "s", value: searchTerm),
                          URLQueryItem(name: "apikey", value: apiKey)]
        var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("Error fetching movies: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let movieResponse = try decoder.decode(MovieResponse.self, from: data)
                completion(movieResponse.Search)
            } catch {
                print("Error decoding movie data: \(error)")
                completion(nil)
            }
        }
        
        task.resume()
    }
}


struct MovieResponse: Decodable {
    let Search: [Movie]?
}

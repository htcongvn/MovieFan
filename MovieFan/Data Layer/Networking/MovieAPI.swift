//
//  MovieAPI.swift
//  MovieFan
//
//  Created by Cong Huynh on 2023-03-04.
//

import Foundation
import Alamofire

// Define a typealias for the getMovies API's callback function
typealias MovieAPIResponse = (Swift.Result<[Movie]? /* a success */, DataError> /* a failure */) -> Void
typealias MovieRatingAPIResponse = (Swift.Result<[MovieRating]?, DataError>) -> Void

// Define API Interface to fetch movies
protocol MovieAPILogic {
    func getMovies(completion: @escaping (MovieAPIResponse)) // We escape the function performing async operation inside of it
    func getMovieRatings(completion: @escaping (MovieRatingAPIResponse))
    func getMovieRatingsStdApi(completion: @escaping (MovieRatingAPIResponse))
}


// Get the popular list of movies, only fetch the fist page
// https://developers.themoviedb.org/3/movies/get-movie-lists
// https://api.themoviedb.org/3/movie/popular?api_key=9b94de2654d82e14b60d1cc6143665af&language=en-US&page=1
// Get one of the movie image in the popular list
// https://image.tmdb.org/t/p/w500/sv1xJUazXeYqALzczSZ3O6nkH75.jpg
class MovieAPI: MovieAPILogic {
    private struct Constants {
        static let apiKey = "9b94de2654d82e14b60d1cc6143665af"
        static let languageLocale = "en-US"
        static let pageValue = 1 // only fetch the fist page
        static let rParameter = "r"
        static let json = "json"
        static let moviesURL =
            "https://api.themoviedb.org/3/movie/popular?api_key=\(apiKey)&language=\(languageLocale)&page=\(pageValue)"
        static let movieRatingsURL =
            "https://api.themoviedb.org/3/movie/top_rated?api_key=\(apiKey)&language=\(languageLocale)&page=\(pageValue)"
    }
    
    func getMovies(completion: @escaping (MovieAPIResponse)) {
        // Prevent AF from retreiving cached responses
        URLCache.shared.removeAllCachedResponses()
        
        AF.request(Constants.moviesURL,
                   method: .get,
                   encoding: URLEncoding.default)
            .validate() // ensure the status code in the range 200...299
            .responseDecodable(of: MovieRootResult.self) { response in // get the response decoded into MovieRootResult type
                switch (response.result) {
                case .failure(let error):
                    completion(.failure(.networkingError(error.localizedDescription)))
                case .success(let moviesListResult):
                    completion(.success(moviesListResult.movies))
                }
            }
    }
    
    // We escape the closure because it returns later, not the same time as this function when it's done the data come back
    func getMovieRatings(completion: @escaping (MovieRatingAPIResponse)) {
        // this prevents AF retrieving cached responses
        URLCache.shared.removeAllCachedResponses()
        
        AF.request(Constants.movieRatingsURL,
                   method: .get,
                   encoding: URLEncoding.default)
        .validate()
        .responseDecodable(of: TopRatedMovieRootResult.self) { response in
            switch response.result {
            case .failure(let error):
                completion(.failure(.networkingError(error.localizedDescription)))
            case .success(let movieRatingsResult):
                completion(.success(movieRatingsResult.topRatedMovies))
            }
        }
    }
    
    // implementation using Apple Standard APIs: URLSession and covennient APIs URLComponents, URLQueryItem and JSONDecoder
    func getMovieRatingsStdApi(completion: @escaping (MovieRatingAPIResponse)) {
        
        URLCache.shared.removeAllCachedResponses()
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.themoviedb.org"
        urlComponents.path = "/3/movie/top_rated"
        urlComponents.queryItems = [URLQueryItem(name: "api_key", value: Constants.apiKey),
                                    URLQueryItem(name: "language", value: Constants.languageLocale),
                                    URLQueryItem(name: "page", value: String(Constants.pageValue))]
        // another way to get url
        // URL(string: Constants.schoolListURL)
        
        if let url = urlComponents.url {
            let urlSession = URLSession(configuration: .default)
            
            let task = urlSession.dataTask(with: url) { data, response, error in
                guard error == nil else {
                    //print("error occured \(String(describing: error?.localizedDescription))")
                    completion(.failure(.networkingError(error?.localizedDescription ?? "Error retrieving movie ratings")))
                    return
                }
                
                if let data = data {
                    let decoder = JSONDecoder()
                    do {
                        let movieRatingsResult = try decoder.decode(TopRatedMovieRootResult.self, from: data)
                        print("Movie ratings \(movieRatingsResult.topRatedMovies.count)")
                        completion(.success(movieRatingsResult.topRatedMovies))
                    } catch let error {
                        print("error during parsing JSON \(error)")
                        completion(.failure(.networkingError(error.localizedDescription )))
                    }
                }
                    
            }
            task.resume()
        }
    }

}

//
//  Movie.swift
//  MovieFan
//
//  Created by Cong Huynh on 2023-03-05.
//

import Foundation
// Get the popular list of movies, only fetch the fist page
// https://developers.themoviedb.org/3/movies/get-movie-lists
// https://api.themoviedb.org/3/movie/popular?api_key=9b94de2654d82e14b60d1cc6143665af&language=en-US&page=1

struct MovieRootResult: Codable {
    let page: Int
    let movies: [Movie]
    // if fetching more than one page is required
    // let totalOfPages: Int
    // let totalOfMovies: Int
    
    enum CodingKeys: String, CodingKey {
        case page
        case movies = "results"
        // if fetching more than one page is required
        // case totalOfPages = "total_pages"
        // case totalOfMovies = "total_results"
    }
}

// Get one of the movie image in the popular list
// https://image.tmdb.org/t/p/w500/sv1xJUazXeYqALzczSZ3O6nkH75.jpg

struct Movie: Codable, Identifiable {
    struct Constants {
        static let baseImageUrl = "https://image.tmdb.org/t/p/"
        static let logoSize = "w45" // w200, w300, w400, w500, w45
        static let largeImageSize = "w500"
    }
    
    var id: Int
    let title: String
    let releaseDate: String
    let imageUrlSuffix: String
    let overview: String
    
    // Build the URL to the movie image
    func getThumbnailImageUrl() -> String {
        return "\(Constants.baseImageUrl)\(Constants.logoSize)\(imageUrlSuffix)"
    }
    
    func getLargeImageUrl() -> String {
        return "\(Constants.baseImageUrl)\(Constants.largeImageSize)\(imageUrlSuffix)"
    }
    
    enum CodingKeys: String, CodingKey {
    case id
    case title
    case releaseDate = "release_date"
    case imageUrlSuffix = "poster_path"
    case overview
    }
}

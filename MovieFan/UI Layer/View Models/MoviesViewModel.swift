//
//  MoviesViewModel.swift
//  MovieFan
//
//  Created by Cong Huynh on 2023-03-05.
//

import Foundation
import Combine

// Use two tools - ObservableObject protocol and @Published property wrapper to define a MoviesViewModel
// which notifies its observers whenever its underline operation of movies retrieval was performed and
// two properties movies and error were modified.
class MoviesViewModel: ObservableObject { // To mark this class as being observable through Combine
    // Simply marking a property with the @Published property wrapper
    // is enough to make the system emit observable events whenever
    // a new value was assigned to it.
    @Published private(set) var movies: [Movie] = []
    @Published private(set) var error: DataError? = nil
    @Published private(set) var movieRatings: [MovieRating] = []
    
    private let apiService: MovieAPILogic
    
    init(apiService: MovieAPILogic = MovieAPI()) {
        self.apiService = apiService
    }
    
    func getMovies() {
        // self was captured weakly in the closure, which subsequently turned it into an optional in the body of the closure.
        // If we use self inside a closure, the closure scope will maintain a strong reference to self for the duration of the scope's life.
        // If self also happens to keep a reference to this closure (in order to call it at some point in the future),
        // we will end up with a strong circular reference cycle (retain cycle) or kind of leak memmory in iOS.
        // [weak self] used in the closure to prevent that retain cycle. But it also turns self into an optional in the process.
        // To deal with this optionality, you can prefix your calls with self?. optional chaining. Or a more popular approach is
        // to create a temporary strong reference to self at the start of the closure by using guard let syntax.
        apiService.getMovies { [weak self] result in
            guard let self = self else { return }
            switch (result) {
            case .failure(let error):
                self.error = error
            case .success(let movies):
                self.movies = movies ?? []
            }
        }
    }
    
    func getMovieRatings() {
        
//        apiService.getMovieRatingsStdApi { [weak self] result in
        apiService.getMovieRatings { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let movieRatings):
                DispatchQueue.main.async {
                    self.movieRatings = movieRatings ?? []
                }
            case .failure(let error):
                self.error = error
            }
        }
    }
    
    func getMovieRatingsVoteAverage(for prefix: Int = 10) -> Double {
        let voteAverages = movieRatings.prefix(prefix).map {
//            movieRating in
//            return movieRating.voteAverage
            // Or short hand in closure $0 is representing first parameter and $1 to second and so on.
             $0.voteAverage
        }
        let sum = voteAverages.reduce(0, +)
//        {
//            partialResult, voteAverage in
//            return partialResult + voteAverage
            // Or short hand
            //$0 + $1
            // Or shortest version: +
//        }
        return sum/Double(prefix)
    }
    
}

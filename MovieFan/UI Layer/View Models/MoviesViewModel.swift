//
//  MoviesViewModel.swift
//  MovieFan
//
//  Created by Cong Huynh on 2023-03-05.
//

import Foundation
import Combine
import Network
import CoreData

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
    
    private var persistentController: MoviePersistentController = MoviePersistentController() // Core Data
    private var moviesFetchRequest: NSFetchRequest<MovieCD> = MovieCD.fetchRequest() // not have the data yet
    
    private var networMonitor: NWPathMonitor = NWPathMonitor()
    private let apiService: MovieAPILogic
    
//    private var queue = DispatchQueue(label: "Monitor")
    
    init(apiService: MovieAPILogic = MovieAPI()) {
        self.apiService = apiService
        
//        self.networMonitor.start(queue: queue)
        self.networMonitor.start(queue: DispatchQueue.global(qos: .userInitiated)) // use system queue which is running background
        
    }
    
    func getMovies() {
        print("getMovies networMonitor: \(networMonitor.currentPath.status)")
        switch (networMonitor.currentPath.status) {
        case .satisfied: // the path connected to the internet
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
                    DispatchQueue.main.async {
                        self.movies = movies ?? []
                        
                        // Prepare incoming serverside movies Id List and Dictionary
                        var moviesIdDict: [Int: Movie] = [:]
                        var moviesIdList: [Int] = []
                        
                        guard let movies = movies,
                                !movies.isEmpty else {
                            return
                        }
                        // movies are now not empty
                        for movie in movies {
                            moviesIdDict[movie.id] = movie
                            // We can do as with .map() outside of the for loop
                            // moviesIdList.append(movie.id)
                        }
                        moviesIdList = movies.map { $0.id }

                        // Get all movies that match incoming server side movies ids
                        // and find any existing movies in the local CoreData
                        self.moviesFetchRequest.predicate = NSPredicate(
                            format: "id IN %@", moviesIdList)
                        
                        // Make a fetch request using predicate
                        let managedObjectContext = self.persistentController.persistentContainer.viewContext

                        let moviesCDList = try? managedObjectContext.fetch(self.moviesFetchRequest)
                        print("moviesCDList: \(String(describing: moviesCDList?.count))")
                        
                        guard let moviesCDList = moviesCDList else {
                            return
                        }
                        
                        var movieIdCDList: [Int] = []
                        
                        // Then update all matching movies to have the same data, i.e. syncing
                        for movieCD in moviesCDList {
                            movieIdCDList.append(Int(movieCD.id))
                            
                            if let movie = moviesIdDict[Int(movieCD.id)] {
                                if (movie.overview != movieCD.overview) {
                                    movieCD.setValue(movie.overview, forKey: "overview")
                                }
                                if (movie.title != movieCD.title) {
                                    movieCD.setValue(movie.title, forKey: "title")
                                }
                                if (movie.imageUrlSuffix != movieCD.imageUrlSuffix) {
                                    movieCD.setValue(movie.imageUrlSuffix, forKey: "imageUrlSuffix")
                                }
                                if (movie.releaseDate != movieCD.releaseDate) {
                                    movieCD.setValue(movie.releaseDate, forKey: "releaseDate")
                                }
                            }
                        }
                        
                        // And add new objects coming from the server side
                        for movie in movies {
                            if !movieIdCDList.contains(movie.id) {
                                let movieCD = MovieCD(context: managedObjectContext) // create object in memory in the context
                                movieCD.id = Int64(movie.id)
                                movieCD.overview = movie.overview
                                movieCD.title = movie.title
                                movieCD.imageUrlSuffix = movie.imageUrlSuffix
                                movieCD.releaseDate = movie.releaseDate
                            }
                        }
                        
                        // FInally save it
                        try? managedObjectContext.save()
                    } // main.async
                } // switch
            }
        default: // not connected to the internet
            // fetch data from CoreData
            do {
                let moviesCDList =
                    try persistentController.persistentContainer.viewContext
                        .fetch(moviesFetchRequest)
                var convertedMovies: [Movie] = []
                for movieCD in moviesCDList {
                    let movie = Movie(id: Int(movieCD.id),
                                      title: movieCD.title ?? "",
                                      releaseDate: movieCD.releaseDate ?? "",
                                      imageUrlSuffix: movieCD.imageUrlSuffix ?? "",
                                      overview: movieCD.overview ?? "")
                    convertedMovies.append(movie)
                }
                movies = convertedMovies
            } catch {
                self.error = .coreDataError("Could not retrieve movies from Core Data")
            }
        }
    }
    
    func getMovieRatings() {
        print("getMovieRatings networMonitor: \(networMonitor.currentPath.status)")
        switch (networMonitor.currentPath.status) {
        case .satisfied: // the path connected to the internet
            apiService.getMovieRatingsStdApi { [weak self] result in
//            apiService.getMovieRatings { [weak self] result in
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
        default: // not connected to the internet
            // fetch data from CoreData
            break
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

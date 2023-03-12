//
//  ContentView.swift
//  MovieFan
//
//  Created by Cong Huynh on 2023-03-04.
//

import SwiftUI
import Charts
import CoreData
import Combine

struct MoviesView: View {
    
    // This is a value that is made available to your views through the application itself - injected by .environmentObject(viewModel) in the app – it’s shared data that every view can read.
    // Because all views point to the same model, if one view changes the model all views immediately update.
    // As the same as property wrapper @ObservedObject, @EnvironmentObject lets Swift UI bind
    // any ObservableObject to our UI view - in our case bind viewModel to MoviesView -
    // and update our view on every change to that object’s published properties.
    // We will get those nice declarative data bindings for free inside of SwiftUI.
    // Note: we can still use he power of Combine itself by subscribing to any observable
    // object’s objectWillChange publisher directly — and then update our UI accordingly.
    @EnvironmentObject var viewModel: MoviesViewModel
    
    // We chose to shield fetch request from the UI and do that within the view model.
    // But it is still available this way to retrieve the data from Core Data directly from UI
    // Fetch from the local CoreData
    // @FetchRequest(sortDescriptors: []) var moviesCDList: FetchedResults<MovieCD>

    var body: some View {
        // Construct our UI based on the current @Publish properties of MoviesViewModel object
        TabView {
            // List Tab
            List {
                Section(header: Text("Popular Movies")) {
                    ForEach(viewModel.movies) { movie in
                        NavigationLink(destination:
                                        MovieDetailsView(movie: movie)) {
                            MovieCardView(movie: movie)
                        }
                    }
                }
            }
            .onAppear {
                // action performed before the first frame of the view appears
                viewModel.getMovies()
            }
//            .onTapGesture {
//                if let movie = viewModel.movies.first {
//                    let movieCD = MovieCD(context: managedObjectContext)
//                    movieCD.id = Int64(movie.id)
//                    movieCD.title = movie.title
//                    movieCD.overview = movie.overview
//                    movieCD.releaseDate = movie.releaseDate
//                    movieCD.imageUrlSuffix = movie.imageUrlSuffix
//                    movieCD.largeImageUrl = movie.getLargeImageUrl()
//                    movieCD.thumbnailImageUrl = movie.getThumbnailImageUrl()
//
//                    try? managedObjectContext.save()
//                }
//            }
            .tabItem {
                Label("Movies",
                      systemImage: "popcorn.fill")
            }
            
            // Chart Tab
            Chart {
                ForEach(viewModel.movieRatings
                    .prefix(10)
//                    .sorted(by: { rating1, rating2 in
//                    rating1.voteCount > rating2.voteCount})
                ) { movie in
//                    LineMark(x: .value("Movies", movie.title),
//                            y: .value("Vote Count", movie.voteCount))
//                    .foregroundStyle(Color.red)
//                    .interpolationMethod(.catmullRom)
//
//                    PointMark(x: .value("Movies", movie.title),
//                            y: .value("Vote Count", movie.voteCount))
//                    .foregroundStyle(by: .value("Movies", movie.title))
//                    .symbol(by: .value("Movies", movie.title))
//                    .accessibilityLabel(movie.title)
//                    .accessibilityValue("\(movie.voteCount) votes")
                    
                    RectangleMark(x: .value("Movies", movie.title),
                                  y: .value("Vote Average", (500 * movie.voteAverage)),
                            width: .ratio(0.6),
                            height: 7)
                    
                    
//                    BarMark(
//                        x: .value("Movie", movie.title),
//                        yStart: .value("Vote Min", (500 * movie.minVote())),
//                        yEnd: .value("Vote Max",(500 * movie.maxVote())),
//                        width: .ratio(0.7)
//                    )
//                    .opacity(0.3)
//                    .foregroundStyle(by: .value("Movies", movie.title))
//                    .symbol(by: .value("Movies", movie.title))
                    
                    BarMark(x: .value("Movies", movie.title),
                            y: .value("Popularity", (20 * movie.popularity)),
                            width: .ratio(0.7)
                    )
                    .opacity(0.2)
                    .foregroundStyle(by: .value("Movies", movie.title))
                    .symbol(by: .value("Movies", movie.title))
                    
                    BarMark(x: .value("Movies", movie.title),
                            y: .value("Vote Count", movie.voteCount))
                    .foregroundStyle(by: .value("Movies", movie.title))
                    .opacity(0.5)
                    
                } // ForEach
                .foregroundStyle(.gray.opacity(0.8))
                
                RuleMark(y: .value("Average", (500 * viewModel.getMovieRatingsVoteAverage(for: 20))))
                    .lineStyle(StrokeStyle(lineWidth: 1))
                    .annotation(position: .top, alignment: .trailing) {
                        Text("Average:  \(viewModel.getMovieRatingsVoteAverage(), format: .number)")
                            .font(.headline)
                            .foregroundStyle(.red)
                    }
            } // Chart
            .chartYScale(domain: 0...30000)
            .chartYAxis(content: {
                AxisMarks(preset: .extended, position: .trailing)
            })
            .chartPlotStyle(content: { plotArea in
                plotArea
                    .frame(height: 400)
                    .background(.green.opacity(0.1))
                    .border(.pink, width: 1)
            })
            .onAppear {
                viewModel.getMovieRatings()
            }
            .padding(15)
            .tabItem {
                Label("Ratings",
                      systemImage: "chart.bar")
            }
        }
        .navigationTitle("Movies")
    }
}

struct MoviesView_Previews: PreviewProvider {
    static var previews: some View {
        MoviesView().environmentObject(MoviesViewModel())
    }
}

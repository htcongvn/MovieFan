//
//  MovieFanApp.swift
//  MovieFan
//
//  Created by Cong Huynh on 2023-03-04.
//

import SwiftUI

@main
struct MovieFanApp: App {
    @StateObject private var persistentController = MoviePersistentController()
    
    let viewModel = MoviesViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                MoviesView()
                    .environmentObject(viewModel) // from network, which is the latest update
                    // Allows to manage the data from CoreData live in memory for better performance
                    // viewContext is inserted into MoviesView
                    .environment(\.managedObjectContext,
                                  persistentController.persistentContainer.viewContext) // from local, which is the copy of it
            }
        }
    }
}

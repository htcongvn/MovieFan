//
//  MovieFanApp.swift
//  MovieFan
//
//  Created by Cong Huynh on 2023-03-04.
//

import SwiftUI

@main
struct MovieFanApp: App {
    let viewModel = MoviesViewModel()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                MoviesView()
                    .environmentObject(viewModel)
            }
        }
    }
}

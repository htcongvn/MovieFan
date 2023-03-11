//
//  MoviePersistentController.swift
//  MovieFan
//
//  Created by Cong Huynh on 2023-03-10.
//

import Foundation
import CoreData

class MoviePersistentController: ObservableObject {
    var persistentContainer = NSPersistentContainer(name: "MovieFan")
    
    init() {
        persistentContainer.loadPersistentStores { storeDescription, error in
            if let error = error {
                print("error: \(error)")
            }
            
            
        }
    }
}

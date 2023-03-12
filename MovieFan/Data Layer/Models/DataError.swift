//
//  DataError.swift
//  MovieFan
//
//  Created by Cong Huynh on 2023-03-05.
//

import Foundation

// Define custom Data Error for the MovieAPI errors
enum DataError: Error {
    case networkingError(String)
    case coreDataError(String)
}

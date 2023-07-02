//
//  NetworkError.swift
//  Ex
//
//  Created by Sharan Thakur on 02/07/23.
//

import Foundation

class NetworkError: Error {
    let message: String
    
    init(message: String) {
        self.message = message
    }
    
    var localizedDescription: String {
        self.message
    }
    
    static let requestFailed = NetworkError(message: "Request Has Failed")
}

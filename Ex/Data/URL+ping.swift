//
//  URL+ping.swift
//  Ex
//
//  Created by Sharan Thakur on 02/07/23.
//

import Foundation

extension URL {
    func ping(timeout: TimeInterval, closure: @escaping (Result<Int, Error>) -> ()) {
        let startTime = Date()
        URLSession(configuration: .default).dataTask(with: URLRequest(url: self, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: timeout)) { (data, response, error) in
            let value = startTime.timeIntervalSinceNow
            
            if let error = error {
                closure(.failure(error))
                return
            }
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                closure(.failure(NetworkError.requestFailed))
                return
            }
            
            let pingms = (fmod(-value, 1) * 1000)
            closure(.success(Int(pingms)))
        }.resume()
    }
}

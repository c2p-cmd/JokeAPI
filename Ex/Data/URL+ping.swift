//
//  URL+ping.swift
//  Ex
//
//  Created by Sharan Thakur on 02/07/23.
//

import Foundation

extension URL {
    func ping(timeout: TimeInterval) async -> Result<Int, Error> {
        do {
            let startTime = Date()
            
            let urlRequest = URLRequest(url: self, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: timeout)
            
            let (_, response) = try await URLSession(configuration: .default).data(for: urlRequest)
            
            let value = startTime.timeIntervalSinceNow
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                return .failure(NetworkError.requestFailed)
            }
            
            let pingms = (fmod(-value, 1) * 1000)
            
            return .success(Int(pingms))
        } catch {
            return .failure(error)
        }
    }
    
    func ping(timeout: TimeInterval, closure: @escaping (Result<Int, Error>) -> ()) {
        let startTime = Date()
        let urlRequest = URLRequest(url: self, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: timeout)
        URLSession(configuration: .default).dataTask(with: urlRequest) { (_: Data?, response: URLResponse?, error: Error?) in
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

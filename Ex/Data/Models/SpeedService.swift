//
//  SpeedService.swift
//  Ex
//
//  Created by Sharan Thakur on 02/07/23.
//

import Foundation

protocol SpeedService {
    func test(
        for url: URL,
        timeout: TimeInterval,
        current: @escaping (Speed, Speed) -> Void,
        final: @escaping (Result<Speed, Error>) -> Void
    )
}

extension SpeedService {
    func calculate(bytes: Int64, seconds: TimeInterval) -> Speed {
        return Speed.speedFrom(bytes: bytes, seconds: seconds)
    }
    
    func sessionConfiguration(timeout: TimeInterval) -> URLSessionConfiguration {
        let sessionConfig: URLSessionConfiguration = .default
        sessionConfig.timeoutIntervalForRequest = timeout
        sessionConfig.timeoutIntervalForResource = timeout
        sessionConfig.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        sessionConfig.urlCache = nil
        return sessionConfig
    }
}

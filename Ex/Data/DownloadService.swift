//
//  DownloadService.swift
//  Ex
//
//  Created by Sharan Thakur on 02/07/23.
//

import Foundation

let url = URL(string: "http://speedtest.tele2.net/10MB.zip")!

class DownloadService: NSObject, SpeedService {
    public static let shared: DownloadService = DownloadService()
    
    private var responseDate: Date?
    private var latestDate: Date?
    private var current: ((Speed, Speed) -> Void)?
    private var final: ((Result<Speed, Error>) -> Void)?
    private var task: URLSessionDownloadTask?
    
    private override init() { }
    
    func test(
        for url: URL,
        in timeout: TimeInterval
    ) async -> Result<Speed, Error> {
        do {
            let res = try await withCheckedThrowingContinuation { continuation in
                self.test(for: url, timeout: 60, current: { _, __ in }, final: {
                    result in continuation.resume(returning: result)
                })
            }
            
            return res
        } catch {
            return .failure(error)
        }
    }
    
    func test(
        for url: URL,
        timeout: TimeInterval,
        current: @escaping (Speed, Speed) -> Void,
        final: @escaping (Result<Speed, Error>) -> Void
    ) {
        self.current = current
        self.final = final
        self.task = URLSession(
            configuration: sessionConfiguration(timeout: timeout),
            delegate: self,
            delegateQueue: OperationQueue.main
        ).downloadTask(with: url)
        print("Starting!")
        self.task?.resume()
    }
    
    func cancelTask() {
        self.task?.cancel()
    }
}

extension DownloadService: URLSessionDownloadDelegate {
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didFinishDownloadingTo location: URL
    ) {
        let result = calculate(bytes: downloadTask.countOfBytesReceived, seconds: Date().timeIntervalSince(self.responseDate!))
        self.final?(.success(result))
        self.responseDate = nil
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        if error != nil {
            print("url session1")
            self.final?(.failure(NetworkError.requestFailed))
            responseDate = nil
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error != nil {
            print(error.debugDescription)
            print("task is \(task.error.debugDescription)")
            
            print("error is \(error.debugDescription)")
            print("url session2")
            self.final?(.failure(NetworkError.requestFailed))
            responseDate = nil
        }
    }
    
    func urlSession(
        _ session: URLSession,
        downloadTask: URLSessionDownloadTask,
        didWriteData bytesWritten: Int64,
        totalBytesWritten: Int64,
        totalBytesExpectedToWrite: Int64
    ) {
        guard let startDate = responseDate, let latesDate = latestDate else {
            responseDate = Date();
            latestDate = responseDate
            print("reset response date")
            return
        }
        let currentTime = Date()
        
        let current = calculate(bytes: bytesWritten, seconds: currentTime.timeIntervalSince(latesDate))
        let average = calculate(bytes: totalBytesWritten, seconds: -startDate.timeIntervalSinceNow)
        
        latestDate = currentTime
        
        self.current?(current, average)
    }
}


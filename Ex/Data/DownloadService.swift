//
//  DownloadService.swift
//  Ex
//
//  Created by Sharan Thakur on 02/07/23.
//

import SwiftUI
import WidgetKit

private let urlString = (configPlist.value(forKey: "SpeedTestFile URL") as? String)!
let url = URL(string: urlString)!

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
            let res: Speed = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Speed, Error>) in
                self.speedTestMayErrorContinuation(for: url, in: timeout, continuation: continuation)
            }
            
            return .success(res)
        } catch {
            return .failure(error)
        }
    }
    
    private func speedTestMayErrorContinuation(
        for url: URL,
        in timeout: TimeInterval,
        continuation: CheckedContinuation<Speed, Error>
    ) {
        test(for: url, timeout: 60) { (result: Result<Speed, Error>) in
            continuation.resume(with: result)
        }
    }
    
    func test(
        for url: URL,
        timeout: TimeInterval,
        final: @escaping (Result<Speed, Error>) -> Void
    ) {
        self.final = final
        self.task = URLSession(
            configuration: sessionConfiguration(timeout: timeout),
            delegate: self,
            delegateQueue: OperationQueue.main
        ).downloadTask(with: url)
        print("Starting!")
        self.task?.resume()
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
    
    func urlSession(
        _ session: URLSession,
        didBecomeInvalidWithError error: Error?
    ) {
        if error != nil {
            print("url session1")
            self.final?(.failure(NetworkError.requestFailed))
            responseDate = nil
        }
    }
    
    func urlSession(
        _ session: URLSession,
        task: URLSessionTask,
        didCompleteWithError error: Error?
    ) {
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
        guard let startDate = responseDate,
              let latesDate = latestDate
        else {
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

// MARK: - WITH Analytics
extension DownloadService {
    func testWithAnalytics(
        for url: URL,
        in timeout: TimeInterval,
        fromWidget widgetFamily: WidgetFamily?
    ) async -> Result<Speed, Error> {
        do {
            let res: Speed = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Speed, Error>) in
                self.speedTestMayErrorContinuation(for: url, in: timeout, continuation: continuation)
            }
            
            await self.analyticsCall(sending: res.pretty, fromWidget: widgetFamily)
            
            return .success(res)
        } catch {
            return .failure(error)
        }
    }
    
    private func analyticsCall(
        sending speed: Speed,
        at date: Date = .now,
        fromWidget widgetFamily: WidgetFamily?
    ) async {
        guard let analyticsUrl = URL(string: "https://5221-219-91-170-183.ngrok-free.app/speed_test/") else {
            print("Invalid url")
            return
        }
        
        let uiDevice = await UIDevice.current
        let name = await uiDevice.name
        let modelName = await uiDevice.model
        let systemVersion = await uiDevice.systemVersion
        let uuid = await uiDevice.identifierForVendor?.uuidString
        
        var requestBody: [String: String] = [
            "Speed" : speed.description,
            "DateTime" : Date.now.formatted(date: .complete, time: .complete),
            "BinaryUrl" : url.absoluteString,
            "Device Name Model" : "\(name) \(modelName)",
            "Device ID" : "\(uuid ?? "nil")",
            "System Version" : systemVersion
        ]
        
        if let widgetFamily {
            requestBody["WidgetFamily"] = widgetFamily.description
        }
        
        var urlRequest = URLRequest(url: analyticsUrl)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = requestBody.percentEncoded()
        
        do {
            let (_, response) = try await URLSession.shared.data(for: urlRequest)
            
            if let httpResponse = response as? HTTPURLResponse {
                print(httpResponse.statusCode)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}

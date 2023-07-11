//
//  ImageProvider.swift
//  JokeWidgetExtension
//
//  Created by Sharan Thakur on 29/06/23.
//

import UIKit

func fetchNASAApod(
    showTitle: Bool?,
    completion: @escaping (NASAApodEntry, Bool) -> Void
) {
    Task {
        let result = await getNASAApod()
        
        switch result {
        case .success(let apodResponse):
            fetchNASAImage(from: apodResponse, showTitle: showTitle ?? false, completion: completion)
            break
        case .failure(let error):
            #if DEBUG
            print(error.localizedDescription)
            #endif
            
            let entry = NASAApodEntry(uiImage: UIImage(named: "error")!, title: error.localizedDescription, showTitle: false)
            completion(entry, true)
            break
        }
    }
}

fileprivate func fetchNASAImage(
    from apodResponse: ApodResponse,
    showTitle: Bool,
    completion: @escaping (NASAApodEntry, Bool) -> Void
) {
    let url = URL(string: apodResponse.url)!
    
    let task = URLSession.shared.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
        #if DEBUG
        if let httpResponse = response as? HTTPURLResponse {
            print(httpResponse.debugDescription)
        }
        #endif
        
        if let data = data {
            guard let uiImage = UIImage(data: data) else {
                let entry = NASAApodEntry(uiImage: UIImage(named: "error")!, title: "Image problem", showTitle: false)
                completion(entry, true)
                return
            }
            let entry = NASAApodEntry(uiImage: uiImage, title: apodResponse.title, showTitle: showTitle)
            completion(entry, false)
        }
        
        if let error = error {
            #if DEBUG
            print(error.localizedDescription)
            #endif
            
            let entry = NASAApodEntry(uiImage: UIImage(named: "error")!, title: error.localizedDescription, showTitle: false)
            completion(entry, true)
        }
    }
    
    task.resume()
}

func fetchAnimalImage(
    of animalType: AnimalType?,
    completion: @escaping (UIImage) -> Void
) {
    let statusCodes: [Int] = [
        100, 101, 102, 103,
        200, 201, 202, 203, 204, 206, 207,
        300, 301, 302, 303, 304, 305, 307, 308,
        400, 401, 402, 403, 404, 405, 406, 407, 408, 409,
        410, 411, 412, 413, 414, 415, 416, 417, 418,
        421, 422, 423, 424, 425, 426, 428, 429, 431, 451,
        500, 501, 502, 503, 504, 505, 506, 507, 508, 510, 511
    ]

    var catUrl: URL {
        let statusCode = statusCodes.randomElement() ?? 100
        return URL(string: "https://http.cat/\(statusCode)")!
    }

    var dogUrl: URL {
        let statusCode = statusCodes.randomElement() ?? 100
        return URL(string: "https://http.dog/\(statusCode).jpg")!
    }
    
    if let animalType = animalType {
        switch animalType {
        case .cat:
            fetchAnimalImage(from: catUrl, completion: completion)
            break
        case .dog:
            fetchAnimalImage(from: dogUrl, completion: completion)
            break
        default:
            fetchAnimalImage(from: dogUrl, completion: completion)
            break
        }
    } else {
        fetchAnimalImage(from: catUrl, completion: completion)
    }
}

fileprivate func fetchAnimalImage(
    from url: URL,
    completion: @escaping (UIImage) -> ()
) {
    let dataTask = URLSession.shared.dataTask(with: url) { (data: Data?, response: URLResponse?, error: Error?) in
        if let httpResponse = response as? HTTPURLResponse {
            print(httpResponse.statusCode)
            print(httpResponse.debugDescription)
        }
        
        if let error = error {
            print(error.localizedDescription)
            completion(UIImage(systemName: "wifi.exclamationmark")!)
            return
        }
        
        if let data = data {
            guard let animalImage = UIImage(data: data) else {
                completion(UIImage(systemName: "wifi.exclamationmark")!)
                return
            }
            if url.description.contains("dog") {
                let resizedImage = animalImage.resized(toWidth: 800)
                completion(resizedImage)
                return
            }
            completion(animalImage)
            return
        }
    }
    
    dataTask.resume()
}


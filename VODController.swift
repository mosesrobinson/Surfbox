//
//  VODController.swift
//  Surfbox
//
//  Created by Moses Robinson on 3/13/19.
//  Copyright © 2019 Moses Robinson. All rights reserved.
//

import UIKit
import CoreData

enum HTTPMethod: String {
    case put = "PUT"
    case delete = "DELETE"
}

enum VODType: String {
    case movie
    case show
}

class VODController {
    
    private let apiKey = "e7af7a85422e3ac13a3197e021cddd5c2e843e6f"
    private let searchBaseURL = URL(string: "https://api-public.guidebox.com/v2/search")!
    private let vodBaseURL = URL(string: "https://api-public.guidebox.com/v2/movies")!
    
    func searchForVOD(with searchTerm: String, completion: @escaping (Error?) -> Void) {
        
        var components = URLComponents(url: searchBaseURL, resolvingAgainstBaseURL: true)
        
        let queryParameters = ["api_key": apiKey,
                               "type" : VODType.movie.rawValue,
                               "field" : "title",
                               "query": searchTerm
        ]
        
        components?.queryItems = queryParameters.map({URLQueryItem(name: $0.key, value: $0.value)})
        
        guard let requestURL = components?.url else {
            completion(NSError())
            return
        }
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            
            if let error = error {
                NSLog("Error searching for VOD with search term \(searchTerm): \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from data task")
                completion(NSError())
                return
            }
            
            do {
                let jsonDecoder = JSONDecoder()
                
                let vodRepresentations = try jsonDecoder.decode(VODRepresentations.self, from: data).results
                self.searchedVODs = vodRepresentations
                completion(nil)
            } catch {
                NSLog("Error decoding JSON data: \(error)")
                completion(error)
            }
            }.resume()
    }
    
    func fetchSingleVOD(with id: Int, completion: @escaping (VODRepresentation?, Error?) -> Void) {
        
        let vodID = String(id)
        
        let url = vodBaseURL.appendingPathComponent(vodID)
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        
        let queryParameters = ["api_key": apiKey,
                               "include_links" : "true"
        ]
        
        components?.queryItems = queryParameters.map({URLQueryItem(name: $0.key, value: $0.value)})
        
        guard let requestURL = components?.url else {
            completion(nil, NSError())
            return
        }
        
        URLSession.shared.dataTask(with: requestURL) { (data, _, error) in
            
            if let error = error {
                NSLog("Error searching for VOD with ID \(id): \(error)")
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                NSLog("No data returned from data task")
                completion(nil, NSError())
                return
            }
            
            do {
                let jsonDecoder = JSONDecoder()
                
                let vodRepresentation = try jsonDecoder.decode(VODRepresentation.self, from: data)
                completion(vodRepresentation, nil)
            } catch {
                NSLog("Error decoding JSON data: \(error)")
                completion(nil, error)
            }
            }.resume()
    }
    
    // MARK: - Properties
    
    var searchedVODs: [VODRepresentation] = []
}

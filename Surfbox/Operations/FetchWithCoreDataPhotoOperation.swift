//
//  FetchWithCoreDataPhotoOperation.swift
//  Surfbox
//
//  Created by Moses Robinson on 3/15/19.
//  Copyright © 2019 Moses Robinson. All rights reserved.
//

import UIKit

class FetchWithCoreDataPhotoOperation: ConcurrentOperation {
    
    init(vod: VOD, session: URLSession = URLSession.shared) {
        self.vod = vod
        self.session = session
        super.init()
    }
    
    override func start() {
        state = .isExecuting
        guard let posterSmall = vod.posterSmall,
            let url = URL(string: posterSmall)?.usingHTTPS else { return }
        
        let task = session.dataTask(with: url) { (data, _, error) in
            defer { self.state = .isFinished }
            if self.isCancelled { return }
            
            if let error = error {
                NSLog("Error fetching data for \(self.vod): \(error)")
                return
            }
            
            guard let data = data else {
                NSLog("No data found")
                return
            }
            
            guard let image = UIImage(data: data) else {
                NSLog("Could not construct image from data")
                return
            }
            
            self.image = image
        }
        task.resume()
        dataTask = task
    }
    
    override func cancel() {
        dataTask?.cancel()
        super.cancel()
    }
    
    // MARK: Properties
    
    let vod: VOD
    
    private let session: URLSession
    
    private(set) var image: UIImage?
    
    private var dataTask: URLSessionDataTask?
}



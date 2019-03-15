//
//  SearchDetailViewController.swift
//  Surfbox
//
//  Created by Moses Robinson on 3/12/19.
//  Copyright © 2019 Moses Robinson. All rights reserved.
//

import UIKit

class SearchDetailViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateViews()
        fetchSingleVOD()
    }
    
    private func fetchSingleVOD() {
        
        guard let vod = vod else { return }
        
        vodController?.fetchSingleVOD(with: vod.id, completion: { (vodRepresentation, error) in
            guard error == nil else { return }
            
            DispatchQueue.main.async {
                self.vod = vodRepresentation
                self.updateViews()
            }
        })
        
    }
    
    private func updateViews() {
        guard let vod = vod else { return }
        
        titleLabel?.text = vod.title
        overviewLabel?.text = vod.overview
        loadedImage(for: vod)
    }
    
    private func loadedImage(for vod: VODRepresentation) {
        
        if let image = largeImageCache.value(for: vod.id) {
            
            posterView.image = image
        } else {
            
            let fetchLargePhotoOperation = FetchLargePhotoOperation(vod: vod)
            
            let cacheOperation = BlockOperation {
                guard let image = fetchLargePhotoOperation.image else { return }
                
                self.largeImageCache.cache(value: image, for: vod.id)
            }
            
            let setImageOperation = BlockOperation {
                guard let image = fetchLargePhotoOperation.image else { return }
                
                self.posterView.image = image
            }
            
            cacheOperation.addDependency(fetchLargePhotoOperation)
            setImageOperation.addDependency(fetchLargePhotoOperation)
            
            photoFetchQueue.addOperations([fetchLargePhotoOperation, cacheOperation], waitUntilFinished: false)
            OperationQueue.main.addOperation(setImageOperation)
            
            storedFetchedOperations[vod.id] = fetchLargePhotoOperation
        }
    }
    
    
    // MARK: - Properties
    
    private var storedFetchedOperations: [Int : FetchLargePhotoOperation] = [:]
    
    private let photoFetchQueue = OperationQueue()
    
    private var largeImageCache: Cache<Int, UIImage> = Cache()
    
    var vodController: VODController?
    
    var vod: VODRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    @IBOutlet var overviewLabel: UITextView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var posterView: UIImageView!
    

}

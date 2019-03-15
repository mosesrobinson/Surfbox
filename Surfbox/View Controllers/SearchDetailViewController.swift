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
        
        setUpApperance()
        updateViews()
        fetchSingleVOD()
    }
    
    @IBAction func sourceButtonTapped(_ sender: Any) {
        guard let vod = vod,
        let link = vod.sources?.first?.link,
        let url = URL(string: link) else {
            sourceButton.setTitle("✔", for: .normal)
            vodController?.create(from: self.vod!)
            return }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    private func fetchSingleVOD() {
        
        guard let vodID = vodID else { return }
        
        vodController?.fetchSingleVOD(with: vodID, completion: { (vodRepresentation, error) in
            guard error == nil else { return }
            
            DispatchQueue.main.async {
                self.vod = vodRepresentation
                self.updateViews()
            }
        })
        
    }
    
    private func updateViews() {
        
        if isViewLoaded {
        guard let vod = vod else { return }
        
        titleLabel.text = vod.title
        overviewLabel.text = vod.overview
        yearLabel.text = "(\(String(vod.releaseYear)))"
        ratingLabel.text = vod.rating
        loadedImage(for: vod)
        
        guard let appName = vod.sources?.first?.appName else { return }
        let image = UIImage(named: appName)
        sourceButton.setImage(image, for: .normal)
        
        let genres = vod.genres?.map({$0.title.capitalized}).joined(separator: ", ")
        genresLabel.text = genres
        }
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
    
    private func setUpApperance() {
        
        posterBackground.backgroundColor = AppearanceHelper.darkNavy
        buttonView.backgroundColor = AppearanceHelper.darkNavy
        contentView.backgroundColor = AppearanceHelper.paperWhite
        overviewLabel.textColor = AppearanceHelper.inkBlack
        titleLabel.textColor = AppearanceHelper.softOrange
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
    
    var vodID: Int?
    
    @IBOutlet var overviewLabel: UITextView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var posterView: UIImageView!
    @IBOutlet var sourceButton: UIButton!
    @IBOutlet var genresLabel: UILabel!
    @IBOutlet var yearLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var posterBackground: UIView!
    @IBOutlet var buttonView: UIView!
    @IBOutlet var contentView: UIView!
    
}

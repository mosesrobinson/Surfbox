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
    }
    
    
    // MARK: - Properties
    
    var vodController: VODController?
    
    var vod: VODRepresentation? {
        didSet {
            updateViews()
        }
    }
    
    @IBOutlet var overviewLabel: UITextView!
    @IBOutlet var titleLabel: UILabel!
    

}

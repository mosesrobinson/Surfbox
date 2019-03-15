//
//  WishTableViewCell.swift
//  Surfbox
//
//  Created by Moses Robinson on 3/15/19.
//  Copyright © 2019 Moses Robinson. All rights reserved.
//

import UIKit

class WishTableViewCell: UITableViewCell {
    
    private func updateViews() {
        guard let vod = vod else { return }
        
        titleLabel.text = vod.title
        yearLabel.text = "(\(String(vod.releaseYear)))"
        ratingLabel.text = vod.rating
    }
    
    // MARK: - Properties
    
    var vod: VOD? {
        didSet {
            updateViews()
        }
    }
    
    
    @IBOutlet var posterView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var yearLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    
}

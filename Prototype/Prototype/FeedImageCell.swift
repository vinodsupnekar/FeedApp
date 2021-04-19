//
//  FeedImageCell.swift
//  Prototype
//
//  Created by vinod supnekar on 14/04/21.
//

import UIKit

class FeedImageCell: UITableViewCell {
    
    @IBOutlet private(set) var locationContainer: UIView!
    @IBOutlet private(set) var locationLabel: UILabel!
    @IBOutlet private(set) var feedImageView: UIImageView!
    @IBOutlet private(set) var descritpionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        feedImageView.alpha = 0
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        
        feedImageView.alpha = 0
    }
    
    func feedIn(_ image: UIImage?) {
        feedImageView.image = image
        
        UIView.animate(withDuration: 0.3, delay: 0.3, options: [], animations: {
            self.feedImageView.alpha = 1
        })
    }
}

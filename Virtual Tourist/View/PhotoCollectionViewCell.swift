//
//  PhotoCollectionViewCell.swift
//  VirtualTourist
//
//  Created by 🍑 on 25/12/2019.
//  Copyright © 2019 udacity. All rights reserved.
//

import UIKit
import Kingfisher

class PhotoCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageCell: UIImageView!
    
    var photo: Photo! {
        
        didSet{
            if let image = photo.fetchImage() {
                imageCell.image = image
            } else if let url = photo.url {
                imageCell.kf.indicatorType = .activity
                imageCell.kf.setImage(with: url, options:[.transition(.fade(0.5))])
            }
        }
    }
}

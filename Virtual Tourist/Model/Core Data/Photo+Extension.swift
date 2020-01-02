//
//  Photo+Extension.swift
//  VirtualTourist
//
//  Created by 🍑 on 10/12/2019.
//  Copyright © 2019 udacity. All rights reserved.
//

import Foundation
import UIKit

extension Photo {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
    
    func fetchImage() -> UIImage? {
        if imageData == nil {
            return nil
        } else {
            return UIImage(data: imageData!)
        }
    }
}

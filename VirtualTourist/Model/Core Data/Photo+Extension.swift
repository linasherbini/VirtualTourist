//
//  Photo+Extension.swift
//  VirtualTourist
//
//  Created by 🍑 on 28/12/2019.
//  Copyright © 2019 udacity. All rights reserved.
//

import Foundation
import UIKit

extension Photo {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
    
}

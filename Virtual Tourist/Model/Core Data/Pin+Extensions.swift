//
//  Pin+Extension.swift
//  VirtualTourist
//
//  Created by 🍑 on 20/12/2019.
//  Copyright © 2019 udacity. All rights reserved.
//

import Foundation
import MapKit


extension Pin {
    
    var coordinate: CLLocationCoordinate2D {
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
        get {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
    }
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        creationDate = Date()
    }
}

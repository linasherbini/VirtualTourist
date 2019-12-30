//
//  PhotosResponse.swift
//  VirtualTourist
//
//  Created by 🍑 on 08/12/2019.
//  Copyright © 2019 udacity. All rights reserved.
//

import Foundation

struct GetPhoto: Codable {
    let id: String
    let owner: String
    let secret: String
    let server: String
    let farm: Int
    let title: String
    let ispublic: Int
    let isfriend: Int
    let isfamily: Int
    
    func createImageURL() -> URL {
        let urlString = "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg"
        return URL(string: urlString)!
    }
}
struct GetPhotos: Codable {
    let page: Int
    let pages: Int
    let perpage: Int
    let photo: [GetPhoto]
}

struct GetPhotosResponse: Codable {
    let photos: GetPhotos
}

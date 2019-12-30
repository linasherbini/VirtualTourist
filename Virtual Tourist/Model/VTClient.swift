//
//  VTClient.swift
//  VirtualTourist
//
//  Created by 🍑 on 08/12/2019.
//  Copyright © 2019 udacity. All rights reserved.
//

import Foundation


class VTClient {
    
    static let key = "98fdd07522052ab26eaa63934748ae29"
    static let secret = "31b516208e67d8bd"
    static let baseURL = "https://api.flickr.com/services/rest​"
    static let method = "flickr.photos.search"
    static var page = 1
   
    static func createURL(_ lat: Double, _ long: Double ) -> URL {
        let urlString = "\(baseURL)?api_key=\(key)&method=\(method)&format=json&lat=\(lat)&lon=\(long)&per_page=12&accuracy=11&nojsoncallback=1&page=\(page)"
        return URL(string: urlString)!
    }
    
    class func getPhoto(lat: Double, long: Double, page: Int, completion: @escaping ([URL?], Error?, String?) -> Void) {
        let request = URLRequest(url: createURL(lat, long))
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion([],error,error?.localizedDescription)
                }
                return
            }
            do {
                let response = try JSONDecoder().decode(GetPhotosResponse.self, from: data)
                let photos = response.photos.photo
                var photosURL = [URL]()
                for photo in photos {
                    photosURL.append(photo.createImageURL())
                }
                /*let pages = response.photos.pages
                page = Int.random(in: 1...pages)*/
                DispatchQueue.main.async {
                    completion(photosURL,nil,"")
                }
            } catch {
                completion([],error,error.localizedDescription)
                print(error)
            }
        }
        task.resume()
    }
    
}

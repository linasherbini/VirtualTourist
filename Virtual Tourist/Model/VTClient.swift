//
//  VTClient.swift
//  VirtualTourist
//
//  Created by 🍑 on 08/12/2019.
//  Copyright © 2019 udacity. All rights reserved.
//

import Foundation
import SwiftyJSON
import Alamofire
import MapKit

//MARK:- Flickr Api
class VTClient {
    
    static let key = "98fdd07522052ab26eaa63934748ae29"
    static let secret = "31b516208e67d8bd"
    static let baseURL="https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(key)&format=json&nojsoncallback=1&per_page=9"
    
    
    static func createPhotoUrl(farmId:String, serverId:String, photoId:String, secret:String) -> String{
        return "https://farm\(farmId).staticflickr.com/\(serverId)/\(photoId)_\(secret).jpg"
    }
    
    static func getPhotos(coordinate: CLLocationCoordinate2D, page: Int, completion: @escaping ([URL], Error?, String?) -> ()){
        
        guard let url = URL(string: VTClient.baseURL + "&lat=\(coordinate.latitude)&lon=\(coordinate.longitude)&page=\(page)&bbox=\(getBBox(lat: coordinate.latitude, long: coordinate.longitude))")
            else {
                print("error unwrapping url")
                return
        }
        
        AF.request(url).validate().responseJSON { response in //creating url request and response using alamofire
            switch response.result {
            case .failure(let error):
                completion([],error,error.errorDescription)
                print(error.localizedDescription)
            case .success(let value):
                let object = JSON(value) //handling json using swiftyJSON
                var photosURLs = [URL]()
                for photo in object["photos"]["photo"] {
                    let urlString = self.createPhotoUrl(farmId: photo.1["farm"].stringValue, serverId: photo.1["server"].stringValue, photoId: photo.1["id"].stringValue, secret: photo.1["secret"].stringValue)
                    let url = URL(string: urlString)
                    photosURLs.append(url!)
                }
                completion(photosURLs,nil,nil)
                print(String(data: try! object.rawData(), encoding: .utf8))
                
            }
        }
    }
    
    static func getBBox(lat:Double, long:Double)->String{
            let value = 0.5
            let minLongitude = max(long - value, -180)
            let minLatitude = max(lat - value, -90)
            let maxLongitude = min(long + value, 180)
            let maxLatitude = min(lat + value, 90)
            return "\(minLongitude),\(minLatitude),\(maxLongitude),\(maxLatitude)"
    }
    
    
}

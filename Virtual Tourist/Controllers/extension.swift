//
//  extension.swift
//  Virtual Tourist
//
//  Created by 🍑 on 22/12/2019.
//  Copyright © 2020 udacity. All rights reserved.
//

import Foundation
import UIKit

fileprivate var activityView: UIView?

extension UIViewController {
    
    //MARK: - Alert
    func showAlertMessage(_ title: String, _ message: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    //MARK: - Activity indicator configurations
    func startAI() {
        activityView = UIView(frame: self.view.bounds)
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center=activityView!.center
        activityIndicator.startAnimating()
        activityView?.addSubview(activityIndicator)
        self.view.addSubview(activityView!)
    }
    
    func stopAI() {
        DispatchQueue.main.async{
            activityView?.removeFromSuperview()
            activityView = nil
        }
    }
    
    
    
}

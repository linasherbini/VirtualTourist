//
//  DataController.swift
//  VirtualTourist
//
//  Created by 🍑 on 28/12/2019.
//  Copyright © 2019 udacity. All rights reserved.
//

import Foundation
import CoreData
import UIKit


// MARK: - Core Data stack

class DataController {
    
    
    static var viewContext:NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    static let persistentContainer = NSPersistentContainer(name: "VirtualTourist")
    
    static func load(completion: (() -> Void)? = nil){
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.autoSaveViewContext()
            completion?()
        }
    }
    
    static func deletePin(_ pin: Pin){
        viewContext.delete(pin)
    }
    
}

extension DataController {
    // MARK: - Core Data Saving support
    static func saveContext () {
        if viewContext.hasChanges {
            do {
                try viewContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    static func autoSaveViewContext(interval: TimeInterval = 10){
        debugPrint("autosaving")
        guard interval > 0 else {
            print("cannot set negative autosaved interval")
            return
        }
        if viewContext.hasChanges{
            try? viewContext.save()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + interval){
            self.autoSaveViewContext(interval: interval)
        }
        
    }
}

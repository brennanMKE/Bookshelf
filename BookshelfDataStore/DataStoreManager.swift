//
//  DataStoreManager.swift
//  Bookshelf
//
//  Created by Brennan Stehling on 3/27/17.
//  Copyright © 2017 SmallSharpTools LLC. All rights reserved.
//

import CoreData

/// Data Store Manager using Core Data
open class DataStoreManager: NSObject {

    public static let sharedInstance = DataStoreManager()

    public var inMemoryDataEnabled: Bool {
        return ProcessInfo.processInfo.environment["InMemoryDataEnabled"]?.uppercased() == "YES"
    }

    public var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }

    // MARK: - Core Data stack -

    public lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */

        let modelName = "Bookshelf"
        let bundle = Bundle(for: type(of: self))
        guard let modelURL = bundle.url(forResource: modelName, withExtension: "momd")
            else {
            fatalError("Unable to located Core Data model")
        }

        let container = NSPersistentContainer(name: modelName, bundle: bundle)

        let description = NSPersistentStoreDescription()
        description.type = self.inMemoryDataEnabled ? NSInMemoryStoreType : NSSQLiteStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving -

    @discardableResult
    public func saveContext () -> Bool {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                debugPrint("Unresolved error \(nserror), \(nserror.userInfo)")
                return false
            }
        }

        return true
    }

}

extension NSPersistentContainer {

    public convenience init(name: String, bundle: Bundle) {
        guard let modelURL = bundle.url(forResource: name, withExtension: "momd"),
            let mom = NSManagedObjectModel(contentsOf: modelURL)
            else {
                fatalError("Unable to located Core Data model")
        }

        self.init(name: name, managedObjectModel: mom)
    }

}

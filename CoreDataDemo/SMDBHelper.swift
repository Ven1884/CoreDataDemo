//
//  SMDBHelper.swift
//
//
//  Created by Zignuts Technolab on 05/12/23.
//

import CoreData

public class SMDBHelper: NSObject {
    public static let shared = SMDBHelper()

    // MARK: - Core Data stack

    private lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "CoreDataDemo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
//            container.viewContext.mergePolicy = NSErrorMergePolicy

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
                print("[SMDBHelper] persistentContainer error: ", error)

//                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    public func managedObjectContext() -> NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    /// Saves the changes to db if any
    public func saveContext() throws {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                print("[SMDBHelper] persistentContainer error: ", error)
                throw error
            }
        }
    }
    
    // MARK: - Helper

    /// Create Insert new object to DB
    /// - Parameters:
    ///     - entity:  Name of entity in which you want to insert data
    ///     - parameter: All the attrbutes with its value
    public func insertInto(entity:String, parameter:[String:Any]) throws  {
        //Retrieve viewcontext
        let manageContext = managedObjectContext()
        //Retrieve entity from context
        let entity = NSEntityDescription.entity(forEntityName: entity, in: manageContext)!
        //Retrieve manage object
        let userObject = NSManagedObject(entity: entity, insertInto: manageContext)
        // Set value of object
        parameter.forEach { (key, value) in
            userObject.setValue(value, forKey: key)
        }
        do {
            //Save context
            try saveContext()
        } catch {
            //Delete memory object if any error and save latest data
            manageContext.delete(userObject)
            try saveContext()
            throw error
        }
    }
    
    /// Fetches list of data from db
    /// - Parameters:
    ///     - entity: Name of entity in which you want to delete
    ///     - predicate: The predicate of the fetch request.
    public func fetch(entity:String, predicate:NSPredicate? = nil) throws -> [NSFetchRequestResult] {
        // Do any additional setup after loading the view.
        let manageContext = managedObjectContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.predicate = predicate
        return try manageContext.fetch(fetchRequest)
    }
    
    /// Updates Record
    /// - Parameters:
    ///     - entity: Name of entity in which you want to delete
    ///     - predicate: The predicate of the fetch request.
    ///     - parameter: All the attrbutes with its value
    public func update(entity:String, predicate:NSPredicate, parameter:[String:Any]) throws -> [NSManagedObject]? {
        
        var allResult:[NSManagedObject]? = nil
        
        //Retrieve viewcontext
        let manageContext = managedObjectContext()
        //Prepare fetch request using predicate
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.predicate = predicate
        //Fetch and update first record
        if let result = try manageContext.fetch(fetchRequest) as? [NSManagedObject] {
            allResult = result
            //Iterate all parameters
            parameter.forEach { (key, value) in
                // Iterate All result and update its value
                result.forEach { item in
                    item.setValue(value, forKey: key)
                }
            }
        }
        try manageContext.save()
        return allResult
    }

    
    /// Find and delete items from given entity
    /// - Parameters:
    ///     - entity:  Name of entity in which you want to delete
    ///     - predicate: The predicate of the fetch request.
    public func delete(entity:String, predicate:NSPredicate) throws {
        let manageContext = managedObjectContext()
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.predicate = predicate
        
        do {
            // fetch result from db
            let result = try manageContext.fetch(fetchRequest) as? [NSManagedObject]
            // Iterarte and delete object
            try result?.forEach { itemToDelete in
                try delete(object: itemToDelete)
            }
        }
    }

    
    /// Removes all the data of given entity
    /// - Parameters:
    ///     - entity: Name of entity in which you want to delete
    public func clearStorage(entity: String) {
        let isInMemoryStore = persistentContainer.persistentStoreDescriptions.reduce(false) {
            return $0 ? true : $1.type == NSInMemoryStoreType
        }

        let managedObjectContext = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        // NSBatchDeleteRequest is not supported for in-memory stores
        if isInMemoryStore {
            do {
                let entities = try managedObjectContext.fetch(fetchRequest)
                for entity in entities {
                    managedObjectContext.delete(entity as! NSManagedObject)
                }
            } catch let error as NSError {
                print(error)
            }
        } else {
            let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
            do {
                try managedObjectContext.execute(batchDeleteRequest)
            } catch let error as NSError {
                print(error)
            }
        }
    }
    
    
    //MARK: - Object Oriented Helper
    /// Deletes given object from DB
    /// - Parameters:
    ///     - object:  NSManagedObject which you want to delete from db
    public func delete(object:NSManagedObject) throws {
        let manageContext = managedObjectContext()
        manageContext.delete(object)
        try SMDBHelper.shared.saveContext()
    }
}

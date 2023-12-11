//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by Zignuts Technolab on 08/12/23.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
//       createUserRecords(userEmail: "abc@gmail.com", userName: "Venkat")
////        fetchAllRecords()
//        updateRecords()
        deleteRecords()
        
    }
    // CREATE RECORDS
    func createUserRecords(userEmail:String,userName:String){
        //1 create appdelegate Singleton object
        guard  let appdelegate = UIApplication.shared.delegate as? AppDelegate else {return }
        
        //2.Access persistentContainer from appdelegate Singleton object and Access the singleton managed object context
        let viewContext = appdelegate.persistentContainer.viewContext
        
        //3. Create an entity
        
        if let userEntity = NSEntityDescription.entity(forEntityName: "Users", in: viewContext){
            //4. Create managed object
            let stud = NSManagedObject(entity: userEntity, insertInto: viewContext)
            stud.setValue(userEmail, forKey: "email")
            stud.setValue(userName, forKey: "name")
        }
        
        //5. Save to persistent store
        if viewContext.hasChanges{
            do{
                try viewContext.save()
                print("Save")
            }catch let error as NSError{
                print("not Save \(error),\(error.userInfo)")
            }
        }
        
    }
    
    // FETCH RECORDS
    func fetchAllRecords(){
        //1 create appdelegate Singleton object
        guard  let appdelegate = UIApplication.shared.delegate as? AppDelegate else {return }
        
        //2.Access persistentContainer from appdelegate Singleton object and Access the singleton managed object context
        let viewContext = appdelegate.persistentContainer.viewContext
        
        //3. Creating fetch request using this we can only filter NSManagedObject having entity name Student.
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        do {
            let result = try viewContext.fetch(fetchRequest)
            for data in result as! [NSManagedObject] {
                print(data.value(forKey: "name") as! String)
            }
            
        } catch {
            print("unable to fetch the data")
        }
    }
    
    //UPDATE RECORDS
    func updateRecords() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let viewContext = appDelegate.persistentContainer.viewContext
        
        // Prepare the request of type NSFetchRequest for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        
        // Add a predicate to fetch specific records you want to update
        fetchRequest.predicate = NSPredicate(format: "name == %@", "Venkat")
        
        do {
            // Fetch the records based on the fetch request
            let fetchedRecords = try viewContext.fetch(fetchRequest) as! [NSManagedObject]
            
            // Update fetched records
            for record in fetchedRecords {
                record.setValue("Hari", forKey: "name")
            }
            
            // Save the context to persist changes
            try viewContext.save()
            fetchAllRecords()
            print("Records updated successfully")
        } catch let error as NSError {
            print("Could not update records. \(error), \(error.userInfo)")
        }
    }
    //DELETE RECORDS
    func deleteRecords() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let viewContext = appDelegate.persistentContainer.viewContext
        
        // Prepare the request of type NSFetchRequest for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        
        // Add a predicate to fetch specific records you want to delete
        fetchRequest.predicate = NSPredicate(format: "name == %@", "Hari")
        
        do {
            // Fetch the records based on the fetch request
            let fetchedRecords = try viewContext.fetch(fetchRequest) as! [NSManagedObject]
            
            // Delete fetched records
            for record in fetchedRecords {
                viewContext.delete(record)
            }
            
            // Save the context to persist changes (deletions)
            try viewContext.save()
            fetchAllRecords()
            print("Records deleted successfully")
        } catch let error as NSError {
            print("Could not delete records. \(error), \(error.userInfo)")
        }
    }

}
    
  

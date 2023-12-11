//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by Zignuts Technolab on 08/12/23.
//

import UIKit
import CoreData

struct UserModel{
    var email:String
    var name:String
}

class ViewController: UIViewController {
    @IBOutlet weak var tblOutlet: UITableView!
    var userArr = [UserModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAllRecords()

    }
    @IBAction func addUserBtnClicked(_ sender: UIBarButtonItem) {
         showTwoTextFieldAlert()
    }
}

// Perform CRUD
extension ViewController{
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
                let name = data.value(forKey: "name") as! String
                let email = data.value(forKey: "email") as! String
                userArr.append(UserModel(email: email, name: name))
            }
            tblOutlet.reloadData()
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
    func deleteRecords(name:String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let viewContext = appDelegate.persistentContainer.viewContext
        
        // Prepare the request of type NSFetchRequest for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        
        // Add a predicate to fetch specific records you want to delete
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            // Fetch the records based on the fetch request
            let fetchedRecords = try viewContext.fetch(fetchRequest) as! [NSManagedObject]
            
            // Delete fetched records
            for record in fetchedRecords {
                viewContext.delete(record)
            }
            
            // Save the context to persist changes (deletions)
            try viewContext.save()
            tblOutlet.reloadData()
            print("Records deleted successfully")
        } catch let error as NSError {
            print("Could not delete records. \(error), \(error.userInfo)")
        }
    }
    
    func showTwoTextFieldAlert() {
        let alertController = UIAlertController(title: "Add User Details", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { (textField1) in
            textField1.placeholder = "Enter User Email"
        }
        
        alertController.addTextField { (textField2) in
            textField2.placeholder = "Enter User Name"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { (action) in
            
            // Handle the user's input when they tap "Submit"
            if let textFields = alertController.textFields {
                let firstTextField = textFields[0]
                let secondTextField = textFields[1]
                
                if let firstText = firstTextField.text, let secondText = secondTextField.text {
                    self.createUserRecords(userEmail: firstText, userName: secondText)
                    self.userArr.append(UserModel(email: firstText, name: secondText))
                    self.tblOutlet.reloadData()
                }
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(submitAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
   
    func updateTextFieldAlert(email: String, name: String, index: Int) {
        let alertController = UIAlertController(title: "Update User Details", message: nil, preferredStyle: .alert)
        alertController.addTextField { (textField1) in
            textField1.text = email
        }
        
        alertController.addTextField { (textField2) in
            textField2.text = name
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let submitAction = UIAlertAction(title: "Submit", style: .default) { [weak self] (action) in
            // Handle the user's input when they tap "Submit"
            if let textFields = alertController.textFields,
               let firstTextField = textFields[0].text,
               let secondTextField = textFields[1].text,
               let weakSelf = self {
                // Update the userArr with the new details at the specified index
                weakSelf.userArr[index] = UserModel(email: firstTextField, name: secondTextField)
                weakSelf.tblOutlet.reloadData()
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(submitAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

extension ViewController:UITableViewDataSource,UITableViewDelegate{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as UITableViewCell
        cell.textLabel?.text = userArr[indexPath.row].name
        cell.detailTextLabel?.text = userArr[indexPath.row].email
        print(userArr[indexPath.row].email)
        tblOutlet.estimatedRowHeight = 68.0
        return cell
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = userArr[indexPath.row]
        updateTextFieldAlert(email: user.email, name: user.name, index: indexPath.row)
        print(user.name)
    }
     func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
         if editingStyle == .delete {
             let user = userArr[indexPath.row]
             deleteRecords(name: user.name)
             userArr.remove(at: indexPath.row)
             tableView.deleteRows(at: [indexPath], with: .fade)
         }
    }
}

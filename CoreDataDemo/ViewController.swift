//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by Zignuts Technolab on 08/12/23.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    @IBOutlet weak var tblOutlet: UITableView!
    var userArr = [UserModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchAllRecords()
    }
    @IBAction func addUserBtnClicked(_ sender: UIBarButtonItem) {
        showAlert(mode: .add)
    }
}
//MARK: - Perform CRUD
extension ViewController{
    //MARK: - CREATE RECORDS
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
    //MARK: - FETCH RECORDS
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
    //MARK: - UPDATE RECORDS
    func updateRecords(name:String,newName:String,email:String,newEmail:String) {
        //create appdelegate Singleton object
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        //Access persistentContainer from appdelegate Singleton object and Access the singleton managed object context
        let viewContext = appDelegate.persistentContainer.viewContext
        // Prepare the request of type NSFetchRequest for the entity
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Users")
        // Add a predicate to fetch specific records you want to update
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        fetchRequest.predicate = NSPredicate(format: "email == %@", email)
        do {
            // Fetch the records based on the fetch request
            let fetchedRecords = try viewContext.fetch(fetchRequest) as! [NSManagedObject]
            // Update fetched records
            for record in fetchedRecords {
                record.setValue(newName, forKey: "name")
                record.setValue(newEmail, forKey: "email")
            }
            // Save the context to persist changes
            try viewContext.save()
            tblOutlet.reloadData()
            print("Records updated successfully")
        } catch let error as NSError {
            print("Could not update records. \(error), \(error.userInfo)")
        }
    }
    //MARK: - DELETE RECORDS
    func deleteRecords(name:String) {
        //create appdelegate Singleton object
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        //Access persistentContainer from appdelegate Singleton object and Access the singleton managed object context
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
    //MARK: - SHOW ALERT
    func showAlert(mode:AlertMode){
        let alertController:UIAlertController
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let submitTitle:String
        // TEXTFIELD'S
        switch mode {
        case .add:
            alertController = UIAlertController(title: "Add User Details", message: nil, preferredStyle: .alert)
            alertController.addTextField { (tf1) in
                tf1.placeholder = "Enter User Email"
            }
            alertController.addTextField { (tf2) in
                tf2.placeholder = "Enter User Name"
            }
            submitTitle = "Submit"
        case let .update(email: email, name: name, _):
            alertController = UIAlertController(title: "Update User Details", message: nil, preferredStyle: .alert)
            alertController.addTextField { (tf1) in
                tf1.text = email
            }
            alertController.addTextField { (tf2) in
                tf2.text = name
            }
            submitTitle = "Update"
        }
        let submitAction = UIAlertAction(title: submitTitle, style: .default) { [weak self] (action) in
            guard let weakself = self,let textFields = alertController.textFields else {return}
            
            switch mode {
            case .add:
                if let firstText = textFields[0].text, !firstText.isEmpty,
                   let secondText = textFields[1].text, !secondText.isEmpty {
                    // Text fields are not empty, proceed with user creation/update
                    weakself.createUserRecords(userEmail: firstText, userName: secondText)
                    weakself.userArr.append(UserModel(email: firstText, name: secondText))
                    weakself.tblOutlet.reloadData()
                } else {
                    // Show an error message as fields are empty
                    weakself.showErrorMessage()
                }
                
            case .update(let email,let name, let index):
                if let firstText = textFields[0].text, !firstText.isEmpty,
                   let secondText = textFields[1].text, !secondText.isEmpty {
                    // Update the userArr with the new details at the specified index
                    weakself.userArr[index] = UserModel(email: firstText, name: secondText)
                    weakself.updateRecords(name: name, newName: secondText,email: email,newEmail: firstText)
                } else {
                    // Show an error message as fields are empty
                    weakself.showErrorMessage()
                }
            }
        }
        alertController.addAction(cancel)
        alertController.addAction(submitAction)
        present(alertController, animated: true, completion: nil)
    }
    //ERROR ALERT
    func showErrorMessage() {
        let errorAlert = UIAlertController(title: "Error", message: "Text fields cannot be empty", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        errorAlert.addAction(okAction)
        present(errorAlert, animated: true, completion: nil)
    }
    
}
//MARK: - TABLE VIEW EXTENSION
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
    func tableView(_ tableView: UITableView,editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    //MARK: - SWIPE TO EDIT AND DELETE FUNCTIONALITY
    func tableView(_ tableView: UITableView,trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Archive action
        let edit = UIContextualAction(style: .normal,title: "Edit") { [weak self] (action, view, completionHandler) in
            if let user = self?.userArr[indexPath.row]{
                self?.showAlert(mode: .update(email: user.email, name: user.name, index: indexPath.row))
            }
            completionHandler(true)
        }
        edit.backgroundColor = .systemGreen
        
        // Trash action
        let delete = UIContextualAction(style: .destructive,title: "Delete") { [weak self] (action, view, completionHandler) in
            guard let self = self else { return } //
            let user = userArr[indexPath.row]
            deleteRecords(name: user.name)
            userArr.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completionHandler(true)
        }
        delete.backgroundColor = .systemRed
        let configuration = UISwipeActionsConfiguration(actions: [edit, delete])
        return configuration
    }
}
//MARK: - USER MODEL
struct UserModel{
    var email:String
    var name:String
}
//MARK: - ALERTMODE ENUM
enum AlertMode{
    case add
    case update(email:String,name:String,index:Int)
}

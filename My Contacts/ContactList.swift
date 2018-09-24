//
//  ViewController.swift
//  My Contacts
//
//  Created by Mac User on 17/09/18.
//  Copyright © 2018 Praveen. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UITableViewController,UISearchBarDelegate {
    
    @IBOutlet weak var searchBar: UISearchBar!
    var searchActive : Bool = false
    

    
    var contacts: [NSManagedObject] = []
    
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        

        fetchContacts()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self,
                                       selector: #selector(self.shouldReload),
                                       name: .dataDownloadCompleted,
                                       object: nil)
        

    }

    override func viewDidLoad() {
        super.viewDidLoad()
        

        searchBar.delegate = self
        
        
    }
    
    
 


    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        

        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath) as! ContactCell
        
        
        let contact = contacts[indexPath.row]
        cell.myCellLabel?.text = contact.value(forKeyPath: "name") as? String
        
        

        cell.userimg.layer.cornerRadius = cell.userimg.frame.size.width/2
        cell.userimg.layer.masksToBounds = true

        
        if let imageData = contact.value(forKey: "imagedata") as? NSData {
            if let image = UIImage(data:imageData as Data) as UIImage! {
                cell.userimg?.image = image
            }
        }



        
        return cell
    }
    
    override  func tableView(_ tableView: UITableView, didSelectRowAt
        indexPath: IndexPath){

        tableView.deselectRow(at: indexPath as IndexPath, animated: true)

        
    }
    


    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNonzeroMagnitude
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let contact = contacts[indexPath.row]
                let controller = segue.destination as! ContactDetailController
                controller.Uname = contact.value(forKeyPath: "name") as! String
                controller.Uemail = contact.value(forKeyPath: "email") as! String
                controller.Uphone = contact.value(forKeyPath: "phone") as! String
                controller.Ucountry = contact.value(forKeyPath: "country") as! String
                controller.Uimage = contact.value(forKey: "imagedata") as! NSData
                

                
            }
        }
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty {
            var predicate: NSPredicate = NSPredicate()
            predicate = NSPredicate(format: "name contains[c] '\(searchText)'")
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedObjectContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"ContactList")
            fetchRequest.predicate = predicate
            do {
                contacts = try managedObjectContext.fetch(fetchRequest) as! [NSManagedObject]
            } catch let error as NSError {
                print("Could not fetch. \(error)")
            }
        }
        else
        {
            fetchContacts()
        }
        tableView.reloadData()
    }

    
    func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    func fetchContacts() {
        let context = getContext()
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ContactList")
        do {
            contacts = try context.fetch(fetchRequest)
        } catch let error as NSError {
            let errorDialog = UIAlertController(title: "Error!", message: "Failed to save! \(error): \(error.userInfo)", preferredStyle: .alert)
            errorDialog.addAction(UIAlertAction(title: "Cancel", style: .cancel))
            present(errorDialog, animated: true)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    @objc func shouldReload() {
        fetchContacts()
        self.tableView.reloadData()
    }

    



}

extension Notification.Name {
    static let dataDownloadCompleted = Notification.Name(
        rawValue: "dataDownloadCompleted")
}


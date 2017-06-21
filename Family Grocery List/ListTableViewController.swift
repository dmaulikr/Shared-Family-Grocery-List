//
//  ListTableViewController.swift
//  Family Grocery List
//
//  Created by Drew Dennistoun on 12/20/16.
//  Copyright © 2016 Drew Dennistoun. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseDatabase

class ListTableViewController: UITableViewController {
    
    var ref: FIRDatabaseReference!
    var currentUser: User!
    var currentListCode: String!
    var items: [GroceryItem] = []
    
    override func viewDidLoad() {
        print("viewDidLoad called")
        super.viewDidLoad()
        
        self.tableView.backgroundView = UIImageView(image: UIImage(named: "iPhoneBG.jpg"))
        
        self.currentListCode = "MyList"
        
        if let newUser = currentUser {
            print("newUser.name = ")
            print(newUser.name)
        }
        print("+++++++======++++++======++++++==== current list is \(self.currentListCode) and current user is \(self.currentUser)")
        ref = FIRDatabase.database().reference().child("lists").child(currentListCode)
        
        let ref2 = ref.child("Items")
        ref2.queryOrdered(byChild: "completed").observe(.value, with: { snapshot in
            var newItems: [GroceryItem] = []
            
            for item in snapshot.children {
                let groceryItem = GroceryItem(snapshot: item as! FIRDataSnapshot)
                newItems.append(groceryItem)
            }
            self.items = newItems
            self.tableView.reloadData()
        })
    }
    
    
    @IBAction func addButtonPressed(_ sender: Any) {
        
        let alert = UIAlertController(title: "Grocery Item",
                                      message: "Add an Item",
                                      preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
        
            // get text field and text from alert controller
            guard let textField = alert.textFields?.first, let text = textField.text else { return }
            
            // create new GroceryItem using current user's data
            let groceryItem = GroceryItem(name: text,
                                          description: text,
                                          completed: false)
            
            // create a child reference thing
            let groceryItemRef = self.ref.child("Items").child(text.lowercased())
            
            // save to database
            groceryItemRef.setValue(groceryItem.toAnyObject())
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
        let groceryItem = items[indexPath.row]
        
       // cell.textLabel?.text = groceryItem.name
       // cell.detailTextLabel?.text = groceryItem.addedByUser
        
        toggleCellCheckbox(cell, isCompleted: groceryItem.completed)
        
        // Configure the cell with the Item
        cell.nameLabel.text = groceryItem.name
        
        
        cell.backgroundColor = UIColor.clear
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let groceryItem = items[indexPath.row]
            groceryItem.ref?.removeValue()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Find the cell the user tapped
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        // Get the corresponding GroceryItem by using the index path's row
        let groceryItem = items[indexPath.row]
        // Negate completed on the grocery item to toggle the status
        let toggledCompletion = !groceryItem.completed
        // Call toggleCellCheckbox to update the visual properties 
        toggleCellCheckbox(cell, isCompleted: toggledCompletion)
        // Update it with fancy Firebase stuff
        groceryItem.ref?.updateChildValues([
                "completed": toggledCompletion
        ])
        //self.viewDidLoad()
    }
    
    func toggleCellCheckbox(_ cell: UITableViewCell, isCompleted: Bool) {
        if !isCompleted {
            cell.accessoryType = .none
            cell.textLabel?.textColor = UIColor.black
        } else {
            cell.accessoryType = .checkmark
            cell.textLabel?.textColor = UIColor.gray
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}











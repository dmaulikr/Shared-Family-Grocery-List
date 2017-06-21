//
//  NewListViewController.swift
//  Family Grocery List
//
//  Created by Drew Dennistoun on 2/1/17.
//  Copyright © 2017 Drew Dennistoun. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class NewListViewController: UIViewController {
    
    var ref: FIRDatabaseReference!
    var currentListCode: String!
    var currentUser: User!
    
    @IBOutlet var listName: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func enterButtonPressed(_ sender: Any) {
        ref = FIRDatabase.database().reference()
        
        let newList = GroceryList(name: listName.text!)
        let listRef = self.ref.child("lists").child(newList.name)
        listRef.setValue(newList.toAnyObject())
        self.currentListCode = newList.name
        
        self.performSegue(withIdentifier: "NewList", sender: nil)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NewList" {
            if let destination = segue.destination as? ListViewController {
                print("+++++++++++++++++++++++++ Current list is \(self.currentListCode))")
                destination.currentListCode = self.currentListCode
            }
        }
    }
    
}

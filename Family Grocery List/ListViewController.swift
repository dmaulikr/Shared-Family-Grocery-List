//
//  ListViewController.swift
//  Family Grocery List
//
//  Created by Drew Dennistoun on 2/20/17.
//  Copyright © 2017 Drew Dennistoun. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseDatabase

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var ref: FIRDatabaseReference!
    var currentListCode: String!
    var items: [GroceryItem] = []
    
    // delegates for passing data between other views and this one
    var cellDelegate: ItemCellDelegate?
    var addDelegate: AddItemDelegate?
    var editDelegate: EditItemDelegate?
    var deleteDelegate: DeleteDelegate?
    
    // value that represents on which cell the edit button was pressed
    var editSection: Int?
    
    // used to fill popup edit view with item's info
    var testEditViewController: EditItemViewController?
    
    // space between cells
    let cellSpacingHeight: CGFloat = 10
    
    // storing list name
    let defaults = UserDefaults.standard
    
    // don't know if I need this
    //var newListCode: String!
    
    // text that will be passed to the delete confirmation view
    var deleteText: String!
    
    // stuff to visually show loading
    @IBOutlet var darkLoadingView: UIView!
    @IBOutlet var loadySpinner: UIActivityIndicatorView!
    
    // the actual table view
    @IBOutlet var tableView: UITableView!
    
    // disable buttons if list is still loading to avoid errors
    var buttonsDisabled: Bool = true
    
    override func viewDidLoad() {
        // stuff is loading
        loadySpinner.startAnimating()
        buttonsDisabled = true
        
        // show toolbar, do more visual stuff
        self.navigationController?.setToolbarHidden(false, animated: true)
        self.navigationController?.toolbar.barTintColor = UIColor(red: 60/255, green: 60/255, blue: 60/255, alpha: 1)
        let insets = UIEdgeInsets(top: 0, left: 0, bottom: 10, right: 0)
        self.tableView.contentInset = insets
        
        super.viewDidLoad()
        
        // remove the extended launch screen after we've segued away from it
        let views = self.navigationController?.viewControllers
        // maybe change this to make sure it's specifically the launch screen that is removed
        if views?.count == 3 {
            self.navigationController?.viewControllers.remove(at: 1)
        }
        
        
        // visual setup stuff for navigation bar and background and whatnot
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.white
        if let theCode = currentListCode {
            self.title = "List Code: \(theCode)"
        }
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        tableView.backgroundColor = UIColor.clear
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1)
        self.navigationController?.navigationBar.isTranslucent = false
        
        // normal tableView setup stuff
        tableView.delegate = self
        tableView.dataSource = self
        
        // if there is a list code then it isn't a new list, setup normally
        if currentListCode != nil {
            ref = FIRDatabase.database().reference().child("lists").child(currentListCode)
            
            let ref2 = ref.child("Items")
            ref2.queryOrdered(byChild: "name").observe(.value, with: { snapshot in
                // populate items array with items in firebase list
                var newItems: [GroceryItem] = []
                for item in snapshot.children {
                    let groceryItem = GroceryItem(snapshot: item as! FIRDataSnapshot)
                    newItems.append(groceryItem)
                }
                self.items = newItems
                self.tableView.reloadData()
                
                // no longer loading
                self.loadySpinner.isHidden = true
                self.loadySpinner.stopAnimating()
                self.darkLoadingView.isHidden = true
                self.buttonsDisabled = false
                
            })
        }
        // if there's no list code then setup as a new list
        else {
            newListSetup()
        }
        
        // stuff for dynamic cell height
        tableView.estimatedRowHeight = 40.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
    }
    
    // there are disallowed characters in firebase that cause the app to crash
    // this method fixes that
    func encodeFirebase(key: String) -> String {
        var newString = key
        newString = newString.replacingOccurrences(of: "_", with: "_U")
        newString = newString.replacingOccurrences(of: ".", with: "_P")
        newString = newString.replacingOccurrences(of: "$", with: "_D")
        newString = newString.replacingOccurrences(of: "#", with: "_H")
        newString = newString.replacingOccurrences(of: "[", with: "_L")
        newString = newString.replacingOccurrences(of: "]", with: "_R")
        newString = newString.replacingOccurrences(of: "/", with: "_S")
        return newString
    }
    
    // all the button press methods
    @IBAction func addButtonPressed(_ sender: Any) {
        if !buttonsDisabled {
            performSegue(withIdentifier: "AddItem", sender: nil)
        }
    }
    
    func editButtonPressed(indexPath: IndexPath) {
        
        let tempItem = items[indexPath.section]
        if !tempItem.completed {
            self.editSection = indexPath.section
            performSegue(withIdentifier: "EditItem", sender: nil)
            
            let editItem: GroceryItem = items[indexPath.section]
            
            self.testEditViewController?.editLabel.text = editItem.name
            self.testEditViewController?.nameField.text = editItem.name
            self.testEditViewController?.descriptionField.text = editItem.description
        }
        
    }
    // if delete pressed, show the popup with delete options
    @IBAction func deleteButtonPressed(_ sender: Any) {
        if !buttonsDisabled {
            performSegue(withIdentifier: "DeleteSegue", sender: nil)
        }
    }
    // both these functions for sharing the list
    @IBAction func shareButtonPressed(_ sender: Any) {
        if !buttonsDisabled {
            let shareText = "Come join my shared grocery list! Use code \(self.currentListCode!) in this app: https://itunes.apple.com/us/app/shared-family-grocery-list/id1230171254?ls=1&mt=8"
            displayShareSheet(shareContent: shareText)
        }
    }
    func displayShareSheet(shareContent: String) {
        let activityViewController = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
        present(activityViewController, animated: true, completion: {})
    }
    
    
    // setting up a new list
    func newListSetup() {
        let newRef = FIRDatabase.database().reference()
        
        // generating a new random list code
        var random = Int(arc4random_uniform(1000000))
        newRef.child("lists").observeSingleEvent(of: .value, with: { snapshot in
            // keep generating a new one until we get one that doesn't exist
            var i = 1
            while snapshot.hasChild(String(random)) {
                random = Int(arc4random_uniform(1000000))
                i+=1
            }
            // make sure it's always six numbers long
            let formatRandom = String(format: "%06d", random)
            // create the list and set the list code to it
            let newChild = newRef.child("lists").child(formatRandom)
            newChild.setValue(formatRandom)
            self.currentListCode = formatRandom
            // make sure it's saved as the default and shown in the title
            self.title = "List Code: \(formatRandom)"
            self.defaults.set(formatRandom, forKey: "previousList")

            // loading the new list like we did the old one
            self.ref = FIRDatabase.database().reference().child("lists").child(self.currentListCode)
            let ref2 = self.ref.child("Items")
            ref2.queryOrdered(byChild: "name").observe(.value, with: { snapshot in
                var newItems: [GroceryItem] = []
                for item in snapshot.children {
                    let groceryItem = GroceryItem(snapshot: item as! FIRDataSnapshot)
                    newItems.append(groceryItem)
                }
                self.items = newItems
                self.tableView.reloadData()
                // stuff is done loading
                self.loadySpinner.isHidden = true
                self.loadySpinner.stopAnimating()
                self.darkLoadingView.isHidden = true
                self.buttonsDisabled = false
                
            })
            // adding an example item for user
            self.itemAdded(itemName: "Example Item", itemDescription: "Example Description")
            // display popup notifying user of list code and how to share it
            self.performSegue(withIdentifier: "NewListCode", sender: nil)
            
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // don't know if I need this line
        super.viewWillAppear(animated)
        // message share option was hiding the toolbar
        self.navigationController?.setToolbarHidden(false, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        UIView.setAnimationsEnabled(true)
        self.navigationController?.setToolbarHidden(true, animated: animated)
        // don't know if I need this line
        super.viewWillDisappear(animated)
    }
    
    // basicallly used for passing data and knowing what to do and when
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        UIView.setAnimationsEnabled(true)
        // if adding an item, show the add item popup and set the delegate
        if segue.identifier == "AddItem" {
            let addItemViewController = segue.destination as! AddItemViewController
            addItemViewController.addDelegate = self
        }
        // if editing an item, show the edit item popup and set the delegate
        else if segue.identifier == "EditItem" {
            let editItemViewController = segue.destination as! EditItemViewController
            editItemViewController.editDelegate = self
            self.testEditViewController = editItemViewController
        }
        // this is for the new list info popup with the list code and share button
        else if segue.identifier == "NewListCode" {
            let newListCodeViewController = segue.destination as! NewListCodeViewController
            newListCodeViewController.listCode = self.currentListCode
        }
        // the delete popup with the options
        else if segue.identifier == "DeleteSegue" {
            let deleteViewController = segue.destination as! DeleteViewController
            deleteViewController.deleteDelegate = self
        }
        // segue to deleteconfirmation if we're deleting all (with corresponding message)
        else if segue.identifier == "DeleteAll" {
            let deleteConfirmationViewController = segue.destination as! DeleteConfirmationViewController
            deleteConfirmationViewController.messageText = deleteText
            // this is used later so we know what to delete
            deleteConfirmationViewController.deleteWhat = "All"
            deleteConfirmationViewController.deleteConfirmationDelegate = self
        }
        // segue to deleteconfirmation if we're only deleting completed (with corresponding message)
        else if segue.identifier == "DeleteCompleted" {
            let deleteConfirmationViewController = segue.destination as! DeleteConfirmationViewController
            deleteConfirmationViewController.messageText = deleteText
            // this is used later so we know what to delete
            deleteConfirmationViewController.deleteWhat = "Completed"
            deleteConfirmationViewController.deleteConfirmationDelegate = self
        }
    }
    
    // restricts length of items and descriptions because I was having problems displaying them if they're too long
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField.text?.characters.count)! >= 50 && range.length == 0 {
            return false
        }
        return true
    }
    
    // this is all fancy setup stuff so I could have dynamic cell heights
    // and also cells with space in between them
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.items.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    // standard tableview delete stuff
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let groceryItem = items[indexPath.section]
            groceryItem.ref?.removeValue()
        }
    }
    
    // setting up the cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // the cell is an ItemCell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
        // the item for this particular cell
        let groceryItem = items[indexPath.section]
        
        // delegate for cell selecing and button tapping because I had to do that manually
        cell.cellDelegate = self
        
        // toggling the cells with completed items
        toggleCellCheckbox(cell, isCompleted: groceryItem.completed)
        
        // Configure the cell with the Item
        cell.nameLabel.text = groceryItem.name
        cell.descriptionLabel?.text = groceryItem.description
        // tag used to know which cell/button is tapped
        cell.tag = indexPath.section
        
        // changing constraints depending on whether or not there's a description
        if (cell.descriptionLabel.text?.isEmpty)! {
            cell.descriptionBottomConstraint.constant = 4
            cell.nameTopConstraint.constant = 12
        }
        else {
            cell.descriptionBottomConstraint.constant = 8
            cell.nameTopConstraint.constant = 8
        }
        
        // some final setup stuff
        cell.backgroundColor = UIColor.clear
        cell.contentView.setNeedsLayout()
        cell.contentView.layoutIfNeeded()
        cell.selectionStyle = .none
        
        return cell
    }
    
    // disabling default select behavior because it wasn't working so I did it manually
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    // toggling the completed status for the cell that is tapped
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Find the cell the user tapped
        guard let cell = tableView.cellForRow(at: indexPath) else { return }
        // Get the corresponding GroceryItem by using the index path's row
        let groceryItem = items[indexPath.section]
        // Negate completed on the grocery item to toggle the status
        let toggledCompletion = !groceryItem.completed
        // Call toggleCellCheckbox to update the visual properties
        toggleCellCheckbox(cell, isCompleted: toggledCompletion)
        // Update it with fancy Firebase stuff
        groceryItem.ref?.updateChildValues([
            "completed": toggledCompletion
            ])
        // don't know if this line is neccessary
        // self.viewDidLoad()
    }

    // toggling completed status for tapped cells (helper method)
    func toggleCellCheckbox(_ cell: UITableViewCell, isCompleted: Bool) {
        
        // all the stuff that will be changed
        let actualCell = cell.contentView.subviews.first as! ItemCell
        let descriptionLabel = actualCell.subviews[1] as! UILabel
        let nameLabel = actualCell.subviews[3] as! UILabel
        let button = actualCell.subviews[0] as! UIButton
        
        // make the cell translucent and the text more gray
        if !isCompleted {
            descriptionLabel.textColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1)
            nameLabel.textColor = UIColor.white
            actualCell.backgroundColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 1)
            button.backgroundColor = UIColor(red: 116/255, green: 116/255, blue: 116/255, alpha: 1)
        } else {
            descriptionLabel.textColor = UIColor.gray
            nameLabel.textColor = UIColor.gray
            actualCell.backgroundColor = UIColor(red: 74/255, green: 74/255, blue: 74/255, alpha: 0.25)
            button.backgroundColor = UIColor(red: 116/255, green: 116/255, blue: 116/255, alpha: 0.25)

        }
    }

}

// extension to know when and in which cell the cell or button was tapped
extension ListViewController: ItemCellDelegate {
    func buttonTapped(location: CGPoint, tag: Int) {
        let cellPath = IndexPath(row: 0, section: tag)
        editButtonPressed(indexPath: cellPath)
    }
    func cellTapped(location: CGPoint, tag: Int) {
        let cellPath = IndexPath(row: 0, section: tag)
        tableView(tableView, didSelectRowAt: cellPath)
    }
}

// exension for creating a new item
extension ListViewController: AddItemDelegate {
    func itemAdded(itemName: String, itemDescription: String) {
        // create new GroceryItem using current user's data
        let groceryItem = GroceryItem(name: itemName,
                                      description: itemDescription,
                                      completed: false)
        // create a child reference thing
        let groceryItemRef = self.ref.child("Items").child(encodeFirebase(key: itemName.lowercased()))
        // save to database
        groceryItemRef.setValue(groceryItem.toAnyObject())
    }
}

// extension for editing existing items
extension ListViewController: EditItemDelegate {
    func itemSaved(itemName: String, itemDescription: String) {
        let editItem = items[self.editSection!]
        editItem.ref?.updateChildValues([
            "name": itemName,
            "description": itemDescription
            ])
    }
}

// extension that notifies what user is about to do and asks for confirmation
extension ListViewController: DeleteDelegate {
    func deleteCompleted() {
        var deleteCount = 0
        if items.count > 0 {
            for groceryItem in items {
                if groceryItem.completed {
                    deleteCount += 1
                }
            }
        }
        var plural = ""
        if deleteCount != 1 {
            plural = "s"
        }
        deleteText = "Are you sure you want to delete \(deleteCount) completed item\(plural)? This cannot be undone."
        performSegue(withIdentifier: "DeleteCompleted", sender: nil)
    }
    func deleteAll() {
        var plural = ""
        if items.count != 1 {
            plural = "s"
        }
        deleteText = "Are you sure you want to delete all \(items.count) item\(plural)? This cannot be undone."
        performSegue(withIdentifier: "DeleteAll", sender: nil)
    }
}

// extension that actually does the deleting once the user confirms it
extension ListViewController: DeleteConfirmationDelegate {
    
    // uses a string to know whether deleting completed or all
    func deleteConfirmed(deleteWhat: String) {
        if items.count > 0 {
            if deleteWhat == "All" {
                for groceryItem in items {
                    groceryItem.ref?.removeValue()
                }
            }
            else if deleteWhat == "Completed" {
                for groceryItem in items {
                    if groceryItem.completed {
                        groceryItem.ref?.removeValue()
                    }
                }
            }
        }
    }
}
















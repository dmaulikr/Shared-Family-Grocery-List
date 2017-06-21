//
//  ViewController.swift
//  Family Grocery List
//
//  Created by Drew Dennistoun on 12/18/16.
//  Copyright © 2016 Drew Dennistoun. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase

class InitialViewController: UIViewController, UITextFieldDelegate {

    var ref: FIRDatabaseReference!
    // string that represents the list in firebase
    var currentListCode: String!
    // defaults used to save lists for automatic login
    let defaults = UserDefaults.standard
    // when auto logging in launchscreen is used to hide transition
    var launchScreen: UIViewController?
    // used for confirming new list so people don't accidentally create new ones
    var newListDelegate: NewListDelegate?
    
    // screen darkens and ActivityIndicator spins while loading list
    @IBOutlet var darkLoadingView: UIView!
    @IBOutlet var loadySpinner: UIActivityIndicatorView!
    
    // text Field for the list code (to join a list)
    @IBOutlet var listText: UITextField!
    
    override func viewDidLoad() {
    
        // not loading anything so hide
        darkLoadingView.isHidden = true
        loadySpinner.isHidden = true
        
        // limits numbers put in textfield
        listText.delegate = self
        
        // if the user has been logged in before
        if (UserDefaults.standard.string(forKey: "previousList") != nil) {
            
            // extend launch screen so we never see login screen (only extends about 0.08 seconds)
            let storyBoard: UIStoryboard = UIStoryboard(name: "LaunchScreen", bundle: nil)
            launchScreen = storyBoard.instantiateViewController(withIdentifier: "StartScreen")
            self.navigationController?.pushViewController(launchScreen!, animated: false)
            
            self.currentListCode = UserDefaults.standard.string(forKey: "previousList")
            
            // segue without animation
            UIView.setAnimationsEnabled(false)
            self.performSegue(withIdentifier: "ExistingList", sender: nil)
        }
        
        super.viewDidLoad()
        
        // visually setting up the view and stuff in it
        let spacerView = UIView(frame: CGRect(x: 0, y: 0, width: 55, height: 10))
        listText.leftViewMode = .always
        listText.leftView = spacerView
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 80/255, green: 80/255, blue: 80/255, alpha: 1)
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.tintColor = UIColor.white
    
        // this is to dismiss keyboard, it was annoying without it
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(InitialViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // don't know if this line should be here
        super.viewWillAppear(animated)
        
        // putting most recent list into the text field
        if (UserDefaults.standard.string(forKey: "previousList") == nil) {
            listText.text = ""
        }
        else {
            listText.text = UserDefaults.standard.string(forKey: "previousList")
        }
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    
    // limit number of allowed characters to 6
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField.text?.characters.count)! >= 6 && range.length == 0 {
            return false
        }
        return true
    }
    
    // enter button pressed to access a list
    @IBAction func enterButtonPressed(_ sender: Any) {
        
        dismissKeyboard()
        
        // if nothing in text field just ignore to avoid error
        if listText.text != "" {
            // visually show that stuff is loading
            darkLoadingView.isHidden = false
            loadySpinner.isHidden = false
            loadySpinner.startAnimating()
            
            // make sure that the list exists
            ref = FIRDatabase.database().reference()
            // should sanitize this to not include whitespace or unallowed characters
            let listName = listText.text
            
            
            ref.child("lists").observeSingleEvent(of: .value, with: { (snapshot) in
                // if the list exists, set the current list code to that list, and segue to it
                if snapshot.hasChild(listName!) {
                    // not loading anymore
                    self.darkLoadingView.isHidden = true
                    self.loadySpinner.isHidden = true
                    self.loadySpinner.stopAnimating()
                    
                    // segue using the given list code
                    self.currentListCode = listName
                    self.performSegue(withIdentifier: "ExistingList", sender: nil)
                    // also set the previous list in UserDefaults to that list for auto login
                    // and set user because I don't know
                    self.defaults.set(self.currentListCode, forKey: "previousList")
                    self.dismissKeyboard()
                }
                    // if the list doesn't exist, alert the user
                else {
                    // not loading anymore
                    self.darkLoadingView.isHidden = true
                    self.loadySpinner.isHidden = true
                    self.loadySpinner.stopAnimating()
                    
                    let alert = UIAlertController(title: "List Doesn't Exist",
                                                  message: "That list code doesn't exist, please try again.",
                                                  preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "Okay",
                                                   style: .default)
                    alert.addAction(okayAction)
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
        
        
    }
    
    // preparing for the segue into the list or for making a new list
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // if we're going to a new list, make sure the destination view controller has the necessary info to load it
        if segue.identifier == "ExistingList" {
            if let destination = segue.destination as? ListViewController {
                destination.currentListCode = self.currentListCode
            }
        }
        // just more stuff to confirm if user wants a new list
        else if segue.identifier == "NewListPopup" {
            let newListPopupViewController = segue.destination as! NewListPopupViewController
            newListPopupViewController.newListDelegate = self
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


extension InitialViewController: NewListDelegate {
    // if user confirms, then segue to new list
    func newListPopupPressed() {
        self.performSegue(withIdentifier: "NewListSegue", sender: nil)
    }
}









//
//  AddItemViewController.swift
//  Family Grocery List
//
//  Created by Drew Dennistoun on 4/5/17.
//  Copyright © 2017 Drew Dennistoun. All rights reserved.
//

import UIKit
import Foundation
import Firebase
import FirebaseDatabase


// delegate used to pass data back and forth between this view and the list
protocol AddItemDelegate {
    func itemAdded(itemName: String, itemDescription: String) -> Void
}

class AddItemViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var nameLabel: UITextField!
    @IBOutlet var descriptionLabel: UITextField!
    var addDelegate: AddItemDelegate?
    
    override func viewDidLoad() {
        
        // visual changes for the UITextFields
        nameLabel.textColor = UIColor.black
        let spacerView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        nameLabel.leftViewMode = .always
        nameLabel.leftView = spacerView
        descriptionLabel.textColor = UIColor.black
        let spacerView2 = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        descriptionLabel.leftViewMode = .always
        descriptionLabel.leftView = spacerView2
        
        // blurring behind the view
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.sendSubview(toBack: blurEffectView)
        
        // textField delegate to limit number of characters
        nameLabel.delegate = self
        descriptionLabel.delegate = self
        
        // tags to perform actions when pressing enter on keyboard
        nameLabel.tag = 0
        descriptionLabel.tag = 1
        
        super.viewDidLoad()
        
        // makes the blurry background completely transparent, was having weird animation issues
        // so I did it manually
        view.subviews.first?.alpha = 0
    }
    
    // limits length of both item name and description to 50 characters, prevents weird layout issues
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField.text?.characters.count)! >= 50 && range.length == 0 {
            return false
        }
        return true
    }
    
    // finishes animation for blurry background, also textField stuff
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        nameLabel.becomeFirstResponder()
        
        UIView.animate(withDuration: 0.25, animations: {
            self.view.subviews.first?.alpha = 0.9
        })
    }
    
    // return button moves to next textField or presses the save button depending on which one
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
            // method for the button that you want to
            // press when second field returns
            addItem(textField)
        }
        return false
    }
    
    // cancel adding a new item
    @IBAction func dismissItem(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // add a new item, use the method in ListViewController delegate to do it
    @IBAction func addItem(_ sender: Any) {
        if nameLabel.text != "" {
            self.addDelegate?.itemAdded(itemName: nameLabel.text!, itemDescription: descriptionLabel.text!)
            dismiss(animated: true, completion: nil)
        }
    }
    
}

//
//  EditItemViewController.swift
//  
//
//  Created by Drew Dennistoun on 4/5/17.
//
//

import UIKit
import Foundation
import Firebase
import FirebaseDatabase

// delegate for passing info between ListViewController and this
protocol EditItemDelegate {
    func itemSaved(itemName: String, itemDescription: String) -> Void
}

class EditItemViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet var editLabel: UILabel!
    @IBOutlet var nameField: UITextField!
    @IBOutlet var descriptionField: UITextField!
    var editDelegate: EditItemDelegate?
    
    override func viewDidLoad() {
        
        // visual stuff for UITextFields
        nameField.textColor = UIColor.black
        let spacerView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        nameField.leftViewMode = .always
        nameField.leftView = spacerView
        descriptionField.textColor = UIColor.black
        let spacerView2 = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        descriptionField.leftViewMode = .always
        descriptionField.leftView = spacerView2
        
        // blurry background
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.sendSubview(toBack: blurEffectView)
        
        // textField delegate so we can limit number of characters
        nameField.delegate = self
        descriptionField.delegate = self
        
        // tags for return button
        nameField.tag = 0
        descriptionField.tag = 1
        
        super.viewDidLoad()
        
        // custom animation for transition
        view.subviews.first?.alpha = 0
        
    }
    
    // limit number of characters to 50 for both fields
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if (textField.text?.characters.count)! >= 50 && range.length == 0 {
            return false
        }
        return true
    }
    
    // move to next textField or asve the item depending on which field it is
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
            saveItem(textField)
        }
        return false
    }
    
    // finish custom animation for transition
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        nameField.becomeFirstResponder()
        
        UIView.animate(withDuration: 0.25, animations: {
            self.view.subviews.first?.alpha = 0.9
        })
    }
    
    // cancel editing item
    @IBAction func dismissItem(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // save item, use delegate method in ListViewController to do so
    @IBAction func saveItem(_ sender: Any) {
        if nameField.text != "" {
            self.editDelegate?.itemSaved(itemName: nameField.text!, itemDescription: descriptionField.text!)
            dismiss(animated: true, completion: nil)
        }
    }
    
}

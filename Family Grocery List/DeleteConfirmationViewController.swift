//
//  DeleteConfirmationViewController.swift
//  Family Grocery List
//
//  Created by Drew Dennistoun on 4/24/17.
//  Copyright © 2017 Drew Dennistoun. All rights reserved.
//

import UIKit
import Foundation

// delegate for if user confirms they want to delete, and what to delete
protocol DeleteConfirmationDelegate {
    func deleteConfirmed(deleteWhat: String)
}

class DeleteConfirmationViewController: UIViewController {
    
    // what the message will say and what will be deleted
    var messageText: String!
    var deleteWhat: String!
    
    // passing back that user confirms they want to delete and what
    var deleteConfirmationDelegate: DeleteConfirmationDelegate?
    
    // the confirmation message
    @IBOutlet var messageLabel: UILabel!
    
    override func viewDidLoad() {
        
        // blurry background
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.sendSubview(toBack: blurEffectView)
        
        super.viewDidLoad()
        
        messageLabel.text = messageText
        
        view.subviews.first?.alpha = 0
        
    }
    
    // finish custom animation for transition
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 0.25, animations: {
            self.view.subviews.first?.alpha = 1//0.9
        })
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func deletePressed(_ sender: Any) {
        // pass message back for what user wants to delete
        dismiss(animated: true, completion: {
            if self.deleteWhat == "All" {
                self.deleteConfirmationDelegate?.deleteConfirmed(deleteWhat: "All")
            }
            else {
                self.deleteConfirmationDelegate?.deleteConfirmed(deleteWhat: "Completed")
            }
        })
        
    }
    

    
}

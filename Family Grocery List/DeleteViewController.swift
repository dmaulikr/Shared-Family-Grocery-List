//
//  DeleteViewController.swift
//  Family Grocery List
//
//  Created by Drew Dennistoun on 4/24/17.
//  Copyright © 2017 Drew Dennistoun. All rights reserved.
//

import UIKit
import Foundation

// delegate to send back whether user wants to delete all or just completed
protocol DeleteDelegate {
    func deleteCompleted()
    func deleteAll()
}

class DeleteViewController: UIViewController {
    
    var deleteDelegate: DeleteDelegate?
    
    override func viewDidLoad() {
        // blurry background
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.sendSubview(toBack: blurEffectView)
        
        super.viewDidLoad()
        
        view.subviews.first?.alpha = 0
    }
    
    // finishing blurry background animation
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 0.25, animations: {
            self.view.subviews.first?.alpha = 0.9
        })
    }
    
    // user wants to delete completed, send it back with delegate method
    @IBAction func deleteCompletedPressed(_ sender: Any) {
        dismiss(animated: true, completion: {
            self.deleteDelegate?.deleteCompleted()
        })
    }
    
    // user wants to delete all, send it back with delegate method
    @IBAction func deleteAllPressed(_ sender: Any) {
        dismiss(animated: true, completion: {
            self.deleteDelegate?.deleteAll()
        })
    }
    
    // user cancelled 
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

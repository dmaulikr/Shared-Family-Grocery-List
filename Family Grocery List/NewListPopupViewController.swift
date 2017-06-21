//
//  NewListPopupViewController.swift
//  
//
//  Created by Drew Dennistoun on 4/21/17.
//
//

import UIKit
import Foundation

// protocol to pass back if user wants to create new list
protocol NewListDelegate {
    func newListPopupPressed()
}

class NewListPopupViewController: UIViewController {

    var newListDelegate: NewListDelegate?

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
    
    // finish custom animation for transition
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 0.25, animations: {
            self.view.subviews.first?.alpha = 1//0.9
        })
    }
    
    // user wants to create new list
    @IBAction func continuePressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        self.newListDelegate?.newListPopupPressed()
    }
    
    // user does not want to create new list
    @IBAction func cancelButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

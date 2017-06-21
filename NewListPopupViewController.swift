//
//  NewListPopupViewController.swift
//  
//
//  Created by Drew Dennistoun on 4/21/17.
//
//

import UIKit
import Foundation
import Firebase
import FirebaseDatabase

class NewListPopupViewController: UIViewController {

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
            self.view.subviews.first?.alpha = 0.9
        })
    }
    
}

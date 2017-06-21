//
//  NewListCodeViewController.swift
//  Pods
//
//  Created by Drew Dennistoun on 4/24/17.
//
//

import UIKit
import Foundation

class NewListCodeViewController: UIViewController {
    
    @IBOutlet var listCodeLabel: UILabel!
    var listCode: String!
    
    override func viewDidLoad() {
        
        // blurry background
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurEffectView)
        view.sendSubview(toBack: blurEffectView)
        
        
        listCodeLabel.text = listCode
        
        super.viewDidLoad()
        
        view.subviews.first?.alpha = 0
        
    }
    
    // finishing blur animation stuff
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIView.animate(withDuration: 0.25, animations: {
            self.view.subviews.first?.alpha = 0.9
        })
    }
    
    // share button stuff
    @IBAction func sharePressed(_ sender: Any) {
        let shareText = "Come join my shared grocery list! Use code \(self.listCode!) in this app: https://itunes.apple.com/us/app/shared-family-grocery-list/id1230171254?ls=1&mt=8"
        displayShareSheet(shareContent: shareText)
    }
    
    func displayShareSheet(shareContent: String) {
        let activityViewController = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
        present(activityViewController, animated: true, completion: {})
    }
    
    @IBAction func dismissPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
}

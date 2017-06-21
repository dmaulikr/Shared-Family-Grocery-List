//
//  ItemCell.swift
//  Family Grocery List
//
//  Created by Drew Dennistoun on 2/18/17.
//  Copyright © 2017 Drew Dennistoun. All rights reserved.
//

import UIKit

protocol ItemCellDelegate {
    func buttonTapped(location: CGPoint, tag: Int) -> Void
    func cellTapped(location: CGPoint, tag: Int) -> Void
}

class ItemCell: UITableViewCell {

    // UI stuff
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var buttonBoy: UIButton!
    var touchStartLocation: CGPoint?
    
    var cellDelegate: ItemCellDelegate?
    
    // constraint stuff
    @IBOutlet var descriptionBottomConstraint: NSLayoutConstraint!
    @IBOutlet var nameTopConstraint: NSLayoutConstraint!
    
    // finding where user touches
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchStartLocation = touches.first?.location(in: self.contentView)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // call method that corresponds with what was touched
        if touches.first?.location(in: self.contentView) == touchStartLocation {
            if let touch = touches.first{
                let location = touch.location(in: self.contentView)
                if buttonBoy.frame.contains(location) {
                    self.cellDelegate?.buttonTapped(location: location, tag: self.tag)
                }
                else {
                    self.cellDelegate?.cellTapped(location: location, tag: self.tag)
                }
                
            }
        }
        
    }

}

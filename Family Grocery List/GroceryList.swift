//
//  GroceryList.swift
//  Family Grocery List
//
//  Created by Drew Dennistoun on 12/20/16.
//  Copyright © 2016 Drew Dennistoun. All rights reserved.
//

import Foundation

struct GroceryList {
    
    let name: String
    
    init(name: String) {
        self.name = name
    }
    
    func toAnyObject() -> Any {
        return [
            "Name" : name
        ]
    }
    
}

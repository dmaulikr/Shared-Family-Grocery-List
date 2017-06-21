//
//  GroceryItem.swift
//  Family Grocery List
//
//  Created by Drew Dennistoun on 2/13/17.
//  Copyright © 2017 Drew Dennistoun. All rights reserved.
//

import Foundation
import FirebaseDatabase

struct GroceryItem {

    let key:String
    let name: String
    let description: String
    let ref: FIRDatabaseReference?
    var completed: Bool
    
    init(name: String, description: String, completed: Bool, key: String = "") {
        self.key = key
        self.name = name
        self.description = description
        self.completed = completed
        self.ref = nil
    }
    
    init(snapshot: FIRDataSnapshot) {
        key = snapshot.key
        let snapshotValue = snapshot.value as! [String: AnyObject]
        name = snapshotValue["name"] as! String
        description = snapshotValue["description"] as! String
        completed = snapshotValue["completed"] as! Bool
        ref = snapshot.ref
    }
    
    func toAnyObject() -> Any {
        return [
            "name": name,
            "description": description,
            "completed": completed
        ]
    }
    
}

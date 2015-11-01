//
//  Expense.swift
//  InventoryDash
//
//  Created by Aboubakar Yaheda on 2015/10/25.
//  Copyright © 2015 Aboubakar Yaheda. All rights reserved.
//

import UIKit

class Expense: NSObject {

    var id: Int
    var name: String
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
}

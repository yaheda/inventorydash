//
//  Expense.swift
//  InventoryDash
//
//  Created by Aboubakar Yaheda on 2015/10/25.
//  Copyright © 2015 Aboubakar Yaheda. All rights reserved.
//

import UIKit

class Expense: NSObject {

    var name: String
    var value: Double
    var color: UIColor
    
    init(name: String, value: Double, color: UIColor) {
        self.name = name
        self.value = value
        self.color = color
    }
}

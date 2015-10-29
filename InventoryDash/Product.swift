//
//  Income.swift
//  InventoryDash
//
//  Created by Aboubakar Yaheda on 2015/10/28.
//  Copyright © 2015 Aboubakar Yaheda. All rights reserved.
//

import UIKit
import Foundation

class Product: NSObject {

    var name: String
    var price: Double = 0.0
    var quantity: Int
    var date: NSDate
    
    init(name: String, price: Double, quantity: Int, date: NSDate) {
        self.name = name
        self.price = price
        self.quantity = quantity
        self.date = date
    }
    
}

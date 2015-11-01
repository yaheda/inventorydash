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

    var id: Int
    var name: String
    var price: Double
    
    var lineItems: [LineItem]!
    
    init(id: Int, name: String, price: Double) {
        self.id = id
        self.name = name
        self.price = price
    }
    
}

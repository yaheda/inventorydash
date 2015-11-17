//
//  Global.swift
//  InventoryDash
//
//  Created by Aboubakar Yaheda on 2015/11/17.
//  Copyright © 2015 Aboubakar Yaheda. All rights reserved.
//

import UIKit

class Global: NSObject {

    static let instance = Global()
    
    let currencyFormatter: NSNumberFormatter! = NSNumberFormatter()
    
    override init() {
        currencyFormatter.numberStyle = .CurrencyStyle
    }
}

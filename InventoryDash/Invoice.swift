//
//  Invoice.swift
//  InventoryDash
//
//  Created by Aboubakar Yaheda on 2015/10/30.
//  Copyright © 2015 Aboubakar Yaheda. All rights reserved.
//

import UIKit

class Invoice: NSObject {
    
    var id: Int
    var date: NSDate
    
    var lineItems: [LineItem]!

    init(id: Int, date: NSDate) {
        self.id = id
        self.date = date
    }
}

//
//  ExpenseItem.swift
//  InventoryDash
//
//  Created by Aboubakar Yaheda on 2015/11/01.
//  Copyright © 2015 Aboubakar Yaheda. All rights reserved.
//

import UIKit

class ExpenseItem: NSObject {

    var expenseId: Int
    var cost: Double
    var date: NSDate
    
    var expense: Expense!
    
    init(expenseId: Int, cost: Double, date: NSDate) {
        self.expenseId = expenseId
        self.cost = cost
        self.date = date
    }
    
}

//
//  CategorisedExpenseItemViewModel.swift
//  InventoryDash
//
//  Created by Aboubakar Yaheda on 2015/11/03.
//  Copyright © 2015 Aboubakar Yaheda. All rights reserved.
//

import UIKit

class CategorisedExpenseItemViewModel: NSObject {

    var expenseId: Int
    var expenseName: String
    var totalCost: Double
    var quantity: Int
    var color: UIColor!
    
    init(expenseId: Int, expenseName: String, totalCost: Double, quantity: Int) {
        self.expenseId = expenseId
        self.expenseName = expenseName
        self.totalCost = totalCost
        self.quantity = quantity
    }
}

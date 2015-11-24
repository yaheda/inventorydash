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
    var vendorId: Int
    var cost: Double
    var date: NSDate
    var invoiceStatus: InvoiceStatus
    
    var expense: Expense!
    
    init(expenseId: Int, vendorId: Int, cost: Double, date: NSDate) {
        self.expenseId = expenseId
        self.vendorId = vendorId
        self.cost = cost
        self.date = date
        self.invoiceStatus = InvoiceStatus.UnPaid
    }
    
    init(expenseId: Int, vendorId: Int, cost: Double, date: NSDate, invoiceStatus: InvoiceStatus) {
        self.expenseId = expenseId
        self.vendorId = vendorId
        self.cost = cost
        self.date = date
        self.invoiceStatus = invoiceStatus
    }
    
    func isOverdue() -> Bool {
        let compareDate = NSDate().add(componentsDict: ["day":-(30)])!
        if date < compareDate {
            return true
        }
        return false
    }
    
}

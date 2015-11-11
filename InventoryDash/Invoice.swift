//
//  Invoice.swift
//  InventoryDash
//
//  Created by Aboubakar Yaheda on 2015/10/30.
//  Copyright © 2015 Aboubakar Yaheda. All rights reserved.
//

import UIKit
import SwiftDate

enum InvoiceStatus: Int {
    case UnPaid = 0
    case Paid = 1
}

class Invoice: NSObject {
    
    var id: Int
    var date: NSDate
    var invoiceStatus: InvoiceStatus
    
    var lineItems: [LineItem]!

    init(id: Int, date: NSDate) {
        self.id = id
        self.date = date
        self.invoiceStatus = InvoiceStatus.UnPaid
    }
    
    init(id: Int, date: NSDate, invoiceStatus: InvoiceStatus) {
        self.id = id
        self.date = date
        self.invoiceStatus = invoiceStatus
    }
    
    func getAmountDue() -> Double {
        var amountDue = 0.0
        for lineItem in lineItems {
            amountDue += lineItem.getTotalPrice()
        }
        return amountDue
    }
    
    func getStatus() -> String {
        if invoiceStatus == InvoiceStatus.Paid {
            return "Paid"
        }
        
        let compareDate = NSDate().add(componentsDict: ["day":-(30)])!
        if date < compareDate {
            return "Overdue"
        }
        
        return "Open"
    }
    
    func isOverdue() -> Bool {
        let compareDate = NSDate().add(componentsDict: ["day":-(30)])!
        if date < compareDate {
            return true
        }
        
        return false
    }
}

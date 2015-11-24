//
//  Vendor.swift
//  InventoryDash
//
//  Created by Aboubakar Yaheda on 2015/11/21.
//  Copyright © 2015 Aboubakar Yaheda. All rights reserved.
//

import UIKit

class Vendor: NSObject {

    var id: Int
    var name: String
    var phone: String
    var email: String
    
    var expenseItems: [ExpenseItem]
    
    init(id: Int, name: String, phone: String, email: String) {
        self.id = id
        self.name = name
        self.phone = phone
        self.email = email
        
        self.expenseItems = [ExpenseItem]()
    }
    
    func getUnpaidBills() -> [ExpenseItem] {
        var results = [ExpenseItem]()
        for bill in expenseItems {
            if bill.invoiceStatus == .UnPaid {
                results.append(bill)
            }
        }
        return results
    }
    
    func getOpenBills() -> [ExpenseItem] {
        var results = [ExpenseItem]()
        for bill in expenseItems {
            if bill.invoiceStatus == .UnPaid && bill.isOverdue() == false {
                results.append(bill)
            }
        }
        return results
    }
    
    func getOverdueBills() -> [ExpenseItem] {
        var results = [ExpenseItem]()
        for bill in expenseItems {
            if bill.invoiceStatus == .UnPaid && bill.isOverdue() == true {
                results.append(bill)
            }
        }
        return results
    }
    
    func getPaidBills() -> [ExpenseItem] {
        var results = [ExpenseItem]()
        for bill in expenseItems {
            if bill.invoiceStatus == .Paid {
                results.append(bill)
            }
        }
        return results
    }

}

//
//  Customer.swift
//  InventoryDash
//
//  Created by Aboubakar Yaheda on 2015/11/12.
//  Copyright © 2015 Aboubakar Yaheda. All rights reserved.
//

import UIKit

class Customer: NSObject {

    var id: Int
    var name: String
    var phone: String
    var email: String
    
    var invoices: [Invoice]
    
    init(id: Int, name: String, phone: String, email: String) {
        self.id = id
        self.name = name
        self.phone = phone
        self.email = email
        
        self.invoices = [Invoice]()
    }
    
    func getOpenInvoices() -> [Invoice] {
        var results = [Invoice]()
        for invoice in invoices {
            if invoice.invoiceStatus == .UnPaid && invoice.isOverdue() == false {
                results.append(invoice)
            }
        }
        return results
    }
    
    func getOverdueItems() -> [Invoice] {
        var results = [Invoice]()
        for invoice in invoices {
            if invoice.invoiceStatus == .UnPaid && invoice.isOverdue() == true {
                results.append(invoice)
            }
        }
        return results
    }
    
    func getPaidItems() -> [Invoice] {
        var results = [Invoice]()
        for invoice in invoices {
            if invoice.invoiceStatus == .Paid {
                results.append(invoice)
            }
        }
        return results
    }
    
}

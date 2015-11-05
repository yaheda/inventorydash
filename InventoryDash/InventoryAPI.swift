//
//  InventoryAPI.swift
//  InventoryDash
//
//  Created by Aboubakar Yaheda on 2015/10/30.
//  Copyright © 2015 Aboubakar Yaheda. All rights reserved.
//

import UIKit
import SwiftDate

class InventoryAPI: NSObject {

    var expenses: [Expense]!
    var expenseItems: [ExpenseItem]!
    var products: [Product]!
    var invoices: [Invoice]!
    var lineItems: [LineItem]!
    
    override init() {
        super.init()
        
        initExpenses()
        initExpensesItems()
        initProducts()
        initInvoices()
        initLineItems()
    }
    
    private func initExpenses() {
        expenses = [Expense]()
        expenses.append(Expense(id: 1, name: "Maintenance and Repairs"))
        expenses.append(Expense(id: 2, name: "Cost of Goods Sold"))
        expenses.append(Expense(id: 3, name: "Legal and Professional Services"))
        expenses.append(Expense(id: 4, name: "Job Expenses"))
        expenses.append(Expense(id: 5, name: "Everything else"))
    }
    
    func getExpense(id id: Int) -> Expense {
        return (expenses.filter({ $0.id == id }).first)!
    }
    
    private func initExpensesItems() {
        expenseItems = [ExpenseItem]()
        for i in 1...11 {
            let month = i < 10 ? "0\(i)" : i.description
            //let date = "2015/\(month)/01".toDate(formatString: "yyyy/MM/dd")!
            let date = NSDate.date(fromString: "2015-\(month)-01T00:00:00.000Z", format: DateFormat.ISO8601)!
            expenseItems.append(ExpenseItem(expenseId: 1, cost: Double(RandomInt(min: 5000, max: 8000)), date: date))
            expenseItems.append(ExpenseItem(expenseId: 2, cost: Double(RandomInt(min: 3000, max: 4500)), date: date))
            expenseItems.append(ExpenseItem(expenseId: 3, cost: Double(RandomInt(min: 3000, max: 4000)), date: date))
            expenseItems.append(ExpenseItem(expenseId: 4, cost: Double(RandomInt(min: 2000, max: 3000)), date: date))
            expenseItems.append(ExpenseItem(expenseId: 5, cost: Double(RandomInt(min: 2000, max: 7000)), date: date))
        }
    }
    
    func getExpenseItems(fromDate fromDate: NSDate) -> [ExpenseItem] {
        let searchExpenseItems = expenseItems.filter({ $0.date > fromDate })
        for expenseItem in searchExpenseItems {
            expenseItem.expense = self.getExpense(id: expenseItem.expenseId)
        }
        return searchExpenseItems
    }
    
    private func initProducts() {
        products = [Product]()
        products.append(Product(id: 1, name: "Sugar Cubes", price: 29))
        products.append(Product(id: 2, name: "Sugar Sachets - White", price: 34))
        products.append(Product(id: 3, name: "Sugar Sachets - Brown", price: 39))
    }
    
    func getProduct(id id: Int) -> Product {
        return (products?.filter({ $0.id == id }).first)!
    }
    
    private func initInvoices() {
        invoices = [Invoice]()
        for i in 1...11 {
            let month = i < 10 ? "0\(i)" : i.description
            //let date = "2015/\(month)/01".toDate(formatString: "yyyy/MM/dd")!
            let date = NSDate.date(fromString: "2015-\(month)-05T22:10:55.200Z", format: DateFormat.ISO8601)!
            invoices.append(Invoice(id: i, date: date))
        }
    }
    
    func getInvoices(fromDate fromDate: NSDate) -> [Invoice] {
        let searchInvoices = invoices.filter({ $0.date > fromDate })
        for invoice in searchInvoices {
            invoice.lineItems = self.getLineItems(invoiceId: invoice.id)
        }
        return searchInvoices
    }
    
    private func initLineItems() {
        lineItems = [LineItem]()
        for invoice in invoices {
            for product in products {
                lineItems.append(LineItem(invoiceId: invoice.id, productId: product.id, quantity: RandomInt(min: 50, max: 500)))
            }
        }
    }
    
    func getLineItems(invoiceId invoiceId: Int) -> [LineItem] {
        let searchLineItems = lineItems.filter({ $0.invoiceId == invoiceId })
        for lineItem in searchLineItems {
            lineItem.product = self.getProduct(id: lineItem.productId)
        }
        
        return searchLineItems
    }
}

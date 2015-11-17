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
    var customers: [Customer]!
    
    private override init() {
        super.init()
        
        initExpenses()
        initExpensesItems()
        initProducts()
        initInvoices()
        initLineItems()
        initCustomers()
    }
    
    static let instance = InventoryAPI()
    
    // MARK: - Expenses
    
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
    
    
    // MARK: - ExpenseItems
    
    private func initExpensesItems() {
        expenseItems = [ExpenseItem]()
        for i in 1...11 {
            let month = i < 10 ? "0\(i)" : i.description
            let date = "2015/\(month)/01".toDate(formatString: "yyyy/MM/dd")!
            //let date = NSDate.date(fromString: "2015-\(month)-01T00:00:00.000Z", format: DateFormat.ISO8601)!
            expenseItems.append(ExpenseItem(expenseId: 1, cost: Double(RandomInt(min: 5000, max: 8000)), date: date))
            expenseItems.append(ExpenseItem(expenseId: 2, cost: Double(RandomInt(min: 30000, max: 45000)), date: date))
            expenseItems.append(ExpenseItem(expenseId: 3, cost: Double(RandomInt(min: 30000, max: 40000)), date: date))
            expenseItems.append(ExpenseItem(expenseId: 4, cost: Double(RandomInt(min: 20000, max: 100000)), date: date))
            expenseItems.append(ExpenseItem(expenseId: 5, cost: Double(RandomInt(min: 20000, max: 50000)), date: date))
        }
    }
    
    func getExpenseItems(fromDate fromDate: NSDate) -> [ExpenseItem] {
        let searchExpenseItems = expenseItems.filter({ $0.date > fromDate })
        for expenseItem in searchExpenseItems {
            expenseItem.expense = self.getExpense(id: expenseItem.expenseId)
        }
        return searchExpenseItems
    }
    
    
    // MARK: - Products
    
    private func initProducts() {
        products = [Product]()
        products.append(Product(id: 1, name: "Sugar Cubes", price: 29))
        products.append(Product(id: 2, name: "Sugar Sachets - White", price: 34))
        products.append(Product(id: 3, name: "Sugar Sachets - Brown", price: 39))
    }
    
    func getProduct(id id: Int) -> Product {
        return (products?.filter({ $0.id == id }).first)!
    }
    
    
    // MARK: - Invoices
    
    private func initInvoices() {
        invoices = [Invoice]()
        var invoiceId = 0
        for i in 1...11 {
            let month = i < 10 ? "0\(i)" : i.description
            
            let nInvoice = RandomInt(min: 1, max: 28)
            
            for j in 1...nInvoice {
                let day = j < 10 ? "0\(j)" : j.description
                let date = "2015/\(month)/\(day)".toDate(formatString: "yyyy/MM/dd")!
                let invoiceStatus = InvoiceStatus(rawValue: RandomInt(min: 0, max: 1))!
                invoices.append(Invoice(id: invoiceId, date: date, customerId: RandomInt(min: 1, max: 10), invoiceStatus: invoiceStatus))
                invoiceId++
            }
            
            
        }
    }
    
    func getInvoices(fromDate fromDate: NSDate) -> [Invoice] {
        let searchInvoices = invoices.filter({ $0.date > fromDate })
        for invoice in searchInvoices {
            invoice.lineItems = self.getLineItems(invoiceId: invoice.id)
        }
        return searchInvoices
    }
    
    func getInvoices(customerId customerId: Int) -> [Invoice] {
        let searchInvoices = invoices.filter({ $0.customerId == customerId })
        for invoice in searchInvoices {
            invoice.lineItems = self.getLineItems(invoiceId: invoice.id)
        }
        return searchInvoices
    }
    
    
    // MARK: - LineItems
    
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
    
    
    // MARK: - Customers
    
    private func initCustomers() {
        customers = [Customer]()
        customers.append(Customer(id: 1, name: "Carrefour", phone: "0117374936", email: "reception@carrefour.com"))
        customers.append(Customer(id: 2, name: "Walmart", phone: "0118463672", email: "accounts@walmart.com"))
        customers.append(Customer(id: 3, name: "Tesco", phone: "0116358593", email: "accounts@tesco.com"))
        customers.append(Customer(id: 4, name: "Metro Group", phone: "0115563746", email: "reception@metrogroup.com"))
        customers.append(Customer(id: 5, name: "AEON", phone: "0119387546", email: "accounts@aeon.com"))
        customers.append(Customer(id: 6, name: "Pick'n'Pay", phone: "0119987653", email: "accounts@picknpay.com"))
        customers.append(Customer(id: 7, name: "Krogger", phone: "0113647364", email: "reception@krogger.com"))
        customers.append(Customer(id: 8, name: "Spar", phone: "0112345345", email: "accounts@spar.com"))
        customers.append(Customer(id: 9, name: "Woolworths", phone: "0116545678", email: "accounts@woolworths.com"))
        customers.append(Customer(id: 10, name: "Rewe", phone: "0119836453", email: "reception@rewe.com"))
    }
    
    func getCustomers() -> [Customer] {
        for customer in customers {
            customer.invoices = getInvoices(customerId: customer.id)
        }
        
        return customers
    }
}

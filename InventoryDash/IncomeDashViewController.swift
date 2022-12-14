//
//  IncomeDashViewController.swift
//  InventoryDash
//
//  Created by Aboubakar Yaheda on 2015/11/14.
//  Copyright © 2015 Aboubakar Yaheda. All rights reserved.
//

import UIKit

@objc public protocol IncomeDashViewDelegate {
    //optional func openInvoicesView_Touched(sender:UITapGestureRecognizer)
}

enum IncomeStatusType: Int {
    case None = 0
    case Open = 1
    case Overdue = 2
    case Paid = 3
}

class IncomeDashViewController: UIViewController {

    weak var delegate : IncomeDashViewDelegate?
    
    @IBOutlet weak var openInvoicesValueLabel: UILabel!
    @IBOutlet weak var openInvoicesDetailLabel: UILabel!
    
    @IBOutlet weak var overdueInvoicesValueLabel: UILabel!
    @IBOutlet weak var overdueInvoicesDetailLabel: UILabel!
    
    @IBOutlet weak var paidInvoicesValueLabel: UILabel!
    @IBOutlet weak var paidInvoicesDetailLabel: UILabel!
    
    
    @IBOutlet weak var openInvoicesView: UIView!
    @IBOutlet weak var overdueInvoicesView: UIView!
    @IBOutlet weak var paidInvoicesView: UIView!
    
    
    var openInvoicesValue: Double = 0.0 {
        didSet {
            openInvoicesValueLabel.text = Global.instance.currencyFormatter.stringFromNumber(openInvoicesValue)
        }
    }
    var openInvoicesCount: Int = 0 {
        didSet {
            openInvoicesDetailLabel.text = "\(openInvoicesCount) Open \(incomeType)"
        }
    }
    var overdueInvoicesValue: Double = 0.0 {
        didSet {
            overdueInvoicesValueLabel.text = Global.instance.currencyFormatter.stringFromNumber(overdueInvoicesValue)
        }
    }
    var overdueInvoicesCount: Int = 0 {
        didSet {
            overdueInvoicesDetailLabel.text = "\(overdueInvoicesCount) Overdue"
        }
    }
    var paidInvoicesValue: Double = 0.0 {
        didSet {
            paidInvoicesValueLabel.text = Global.instance.currencyFormatter.stringFromNumber(paidInvoicesValue)
        }
    }
    var paidInvoicesCount: Int = 0 {
        didSet {
            paidInvoicesDetailLabel.text = "\(paidInvoicesCount) Paid Last 30 Days"
        }
    }
    
    var last30Days: NSDate!
    var incomeType: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        openInvoicesView.backgroundColor = UIColor.flatYellowColor()
        last30Days = NSDate().add(componentsDict: ["month":-1])
    }
    
    func updateIncomePanel(invoices invoices: [Invoice]) {
        incomeType = "Invoice"
        
        openInvoicesValue = 0.0
        openInvoicesCount = 0
        overdueInvoicesValue = 0.0
        overdueInvoicesCount = 0
        paidInvoicesValue = 0.0
        paidInvoicesCount = 0
        
        for invoice in invoices {
            if (invoice.invoiceStatus == InvoiceStatus.Paid) {
                if (invoice.date > last30Days) {
                    paidInvoicesCount++
                    paidInvoicesValue += invoice.getAmountDue()
                }
            } else {
                if (invoice.isOverdue() == true) {
                    overdueInvoicesCount++
                    overdueInvoicesValue += invoice.getAmountDue()
                } else {
                    openInvoicesCount++
                    openInvoicesValue += invoice.getAmountDue()
                }
            }
        }
    }
    
    func updateIncomePanel(expenseItems expenseItems: [ExpenseItem]) {
        incomeType = "Bill"

        openInvoicesValue = 0.0
        openInvoicesCount = 0
        overdueInvoicesValue = 0.0
        overdueInvoicesCount = 0
        paidInvoicesValue = 0.0
        paidInvoicesCount = 0
        
        for expenseItem in expenseItems {
            if (expenseItem.invoiceStatus == InvoiceStatus.Paid) {
                if (expenseItem.date > last30Days) {
                    paidInvoicesCount++
                    paidInvoicesValue += expenseItem.cost
                }
            } else {
                if (expenseItem.isOverdue() == true) {
                    overdueInvoicesCount++
                    overdueInvoicesValue += expenseItem.cost
                } else {
                    openInvoicesCount++
                    openInvoicesValue += expenseItem.cost
                }
            }
        }
    }
    
}

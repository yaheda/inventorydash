//
//  CustomerViewController.swift
//  InventoryDash
//
//  Created by Aboubakar Yaheda on 2015/11/13.
//  Copyright © 2015 Aboubakar Yaheda. All rights reserved.
//

import UIKit

class CustomerViewController: UIViewController, ENSideMenuDelegate, UITableViewDelegate, IncomeDashViewDelegate {

    @IBOutlet weak var incomeView: UIView!
    @IBOutlet weak var customerTableView: UITableView!
    
    //var inventoryAPI: InventoryAPI!
    
    var customers: [Customer]!
    var filteredCustomers: [Customer]!
    
    var incomeStatusType: IncomeStatusType = IncomeStatusType.None
    
    var incomeDashViewController: IncomeDashViewController!
    var originalInvoiceOriginY: CGFloat = 0.0
    
    var openInvoicesView_IsSelected: Bool = false
    var overdueInvoicesView_IsSelected: Bool = false
    var paidInvoicesView_IsSelected: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sideMenuController()?.sideMenu?.delegate = self

        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        incomeDashViewController = mainStoryboard.instantiateViewControllerWithIdentifier("IncomeDashViewController") as! IncomeDashViewController
        //incomeDashViewController.delegate = self
        incomeView.addSubview(incomeDashViewController.view)
        
        //inventoryAPI = InventoryAPI()
        
        let last12MonthDate = NSDate().add(componentsDict: ["month":-12])!//.toLocalTime()
        let invoiceItems = InventoryAPI.instance.getInvoices(fromDate: last12MonthDate)
        incomeDashViewController.updateIncomePanel(invoices: invoiceItems)
        
        customers = InventoryAPI.instance.getCustomers()
        filteredCustomers = [Customer]()
        for customer in customers {
            filteredCustomers.append(customer)
        }
        
        incomeDashViewController.openInvoicesView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "openInvoicesView_Touched:"))
        incomeDashViewController.overdueInvoicesView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "overdueInvoicesView_Touched:"))
        incomeDashViewController.paidInvoicesView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "paidInvoicesView_Touched:"))
        
        originalInvoiceOriginY = incomeDashViewController.openInvoicesView.frame.origin.y
    }
    
    func resetIncomeFilterOrigin() {
        UIView.animateWithDuration(0.5) { [unowned self] in
            self.incomeDashViewController.openInvoicesView.frame.origin.y = self.originalInvoiceOriginY
            self.incomeDashViewController.overdueInvoicesView.frame.origin.y = self.originalInvoiceOriginY
            self.incomeDashViewController.paidInvoicesView.frame.origin.y = self.originalInvoiceOriginY
        }
    }
    
    func animateOpenInvoiceFilter() {
        UIView.animateWithDuration(0.5) { [unowned self] in
            self.incomeDashViewController.openInvoicesView.frame.origin.y -= 10
        }
    }
    
    func animateOverdueInvoiceFilter() {
        UIView.animateWithDuration(0.5) { [unowned self] in
            self.incomeDashViewController.overdueInvoicesView.frame.origin.y -= 10
        }
    }
    
    func animatePaidInvoiceFilter() {
        UIView.animateWithDuration(0.5) { [unowned self] in
            self.incomeDashViewController.paidInvoicesView.frame.origin.y -= 10
        }
    }
    
    func openInvoicesView_Touched(sender:UITapGestureRecognizer) {
        filteredCustomers = [Customer]()
        resetIncomeFilterOrigin()
        overdueInvoicesView_IsSelected = false
        paidInvoicesView_IsSelected = false
        
        if openInvoicesView_IsSelected {
            incomeStatusType = .None
            for customer in customers {
                filteredCustomers.append(customer)
            }
        } else {
            incomeStatusType = .Open
            animateOpenInvoiceFilter()
            for customer in customers {
                if customer.getOpenInvoices().count > 0 {
                    filteredCustomers.append(customer)
                }
            }
        }
        
        openInvoicesView_IsSelected = !openInvoicesView_IsSelected
        customerTableView.reloadData()
    }
    
    func overdueInvoicesView_Touched(sender:UITapGestureRecognizer) {
        filteredCustomers = [Customer]()
        resetIncomeFilterOrigin()
        openInvoicesView_IsSelected = false
        paidInvoicesView_IsSelected = false
        
        if overdueInvoicesView_IsSelected {
            incomeStatusType = .None
            for customer in customers {
                filteredCustomers.append(customer)
            }
        } else {
            incomeStatusType = .Overdue
            animateOverdueInvoiceFilter()
            for customer in customers {
                if customer.getOverdueItems().count > 0 {
                    filteredCustomers.append(customer)
                }
            }
        }
        
        overdueInvoicesView_IsSelected = !overdueInvoicesView_IsSelected
        customerTableView.reloadData()
    }
    
    func paidInvoicesView_Touched(sender:UITapGestureRecognizer) {
        filteredCustomers = [Customer]()
        resetIncomeFilterOrigin()
        openInvoicesView_IsSelected = false
        overdueInvoicesView_IsSelected = false
        
        if paidInvoicesView_IsSelected {
            incomeStatusType = .None
            for customer in customers {
                filteredCustomers.append(customer)
            }
        } else {
            incomeStatusType = .Paid
            animatePaidInvoiceFilter()
            for customer in customers {
                let compareDate = NSDate().add(componentsDict: ["day":-(30)])!
                for invoice in customer.getPaidItems() {
                    if invoice.date > compareDate {
                        filteredCustomers.append(customer)
                        break
                    }
                }
            }
        }
        
        paidInvoicesView_IsSelected = !paidInvoicesView_IsSelected
        customerTableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredCustomers.count
    }
    
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: CustomerTableViewCell! = tableView.dequeueReusableCellWithIdentifier("CustomerTableViewCell") as! CustomerTableViewCell
        if(cell == nil) {
            cell = NSBundle.mainBundle().loadNibNamed("CustomerTableViewCell", owner: self, options: nil)[0] as! CustomerTableViewCell;
        }
        
        cell.name.text = filteredCustomers[indexPath.row].name
        cell.phone.text = filteredCustomers[indexPath.row].phone
        cell.email.text = filteredCustomers[indexPath.row].email
        
        var balance = 0.0
        var count = 0
        var statusText = ""
        
        switch incomeStatusType {
            
        case .None:
            for invoice in filteredCustomers[indexPath.row].getUnpaidInvoices() {
                balance += invoice.getAmountDue()
                count++
            }
            statusText = "Unpaid"
        case .Open:
            for invoice in filteredCustomers[indexPath.row].getOpenInvoices() {
                balance += invoice.getAmountDue()
                count++
            }
            statusText = "Open"
        case .Overdue:
            for invoice in filteredCustomers[indexPath.row].getOverdueItems() {
                balance += invoice.getAmountDue()
                count++
            }
            statusText = "Overdue"
        case .Paid:
            let compareDate = NSDate().add(componentsDict: ["day":-(30)])!
            for invoice in filteredCustomers[indexPath.row].getPaidItems() {
                if invoice.date > compareDate {
                    balance += invoice.getAmountDue()
                    count++
                }
            }
            statusText = "Paid"
        }
        
        
        
        cell.balance.text = Global.instance.currencyFormatter.stringFromNumber(balance)!
        
        var invoiceStatus = "-"
        if (count > 0) {
            invoiceStatus = "\(count) \(statusText) invoice\(count != 1 ? "s" : "")"
        }
        
        cell.invoiceStatus.text = invoiceStatus
        
        return cell as CustomerTableViewCell
    }
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        tableView.backgroundView = nil
        tableView.backgroundColor = UIColor.clearColor()
        
        cell.backgroundColor = UIColor.clearColor()
        cell.contentView.backgroundColor = UIColor.clearColor()
    }
    
    @IBAction func toggleSideMenu(sender: UIBarButtonItem) {
        toggleSideMenuView()
    }
}

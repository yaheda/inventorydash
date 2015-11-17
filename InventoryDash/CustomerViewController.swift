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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sideMenuController()?.sideMenu?.delegate = self

        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        let incomeDashViewController = mainStoryboard.instantiateViewControllerWithIdentifier("IncomeDashViewController") as! IncomeDashViewController
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
    }
    
    func openInvoicesView_Touched(sender:UITapGestureRecognizer) {
        incomeStatusType = .Open
        
        filteredCustomers = [Customer]()
        for customer in customers {
            if customer.getOpenInvoices().count > 0 {
                filteredCustomers.append(customer)
            }
        }
        
        customerTableView.reloadData()
    }
    
    func overdueInvoicesView_Touched(sender:UITapGestureRecognizer) {
        incomeStatusType = .Overdue
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
        var unpaidCount = 0
        for invoice in filteredCustomers[indexPath.row].invoices {
            if invoice.invoiceStatus == InvoiceStatus.UnPaid {
                balance += invoice.getAmountDue()
                unpaidCount++
            }
        }
        
        cell.balance.text = Global.instance.currencyFormatter.stringFromNumber(balance)!
        
        var invoiceStatus = "-"
        if (unpaidCount > 0) {
            invoiceStatus = "\(unpaidCount) Unpaid invoice\(unpaidCount != 1 ? "s" : "")"
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

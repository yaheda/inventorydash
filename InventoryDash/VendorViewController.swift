//
//  VendorViewController.swift
//  InventoryDash
//
//  Created by Aboubakar Yaheda on 2015/11/20.
//  Copyright © 2015 Aboubakar Yaheda. All rights reserved.
//

import UIKit

class VendorViewController: UIViewController, ENSideMenuDelegate, UITableViewDelegate {
    
    @IBOutlet weak var incomeView: UIView!
    @IBOutlet weak var vendorTableView: UITableView!
    
    var vendors: [Vendor]!
    var filteredVendors: [Vendor]!
    
    var incomeStatusType: IncomeStatusType = IncomeStatusType.None
    
    var incomeDashViewController: IncomeDashViewController!
    var originalInvoiceOriginY: CGFloat = 0.0
    
    var openBillsView_IsSelected: Bool = false
    var overdueBillsView_IsSelected: Bool = false
    var paidBillsView_IsSelected: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sideMenuController()?.sideMenu?.delegate = self
        
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        incomeDashViewController = mainStoryboard.instantiateViewControllerWithIdentifier("IncomeDashViewController") as! IncomeDashViewController
        incomeView.addSubview(incomeDashViewController.view)
        
        let last12MonthDate = NSDate().add(componentsDict: ["month":-12])!
        let expenseItems = InventoryAPI.instance.getExpenseItems(fromDate: last12MonthDate)
        incomeDashViewController.updateIncomePanel(expenseItems: expenseItems)
        
        vendors = InventoryAPI.instance.getVendors()
        filteredVendors = [Vendor]()
        for vendor in vendors {
            filteredVendors.append(vendor)
        }
        
        incomeDashViewController.openInvoicesView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "openBillsView_Touched:"))
        incomeDashViewController.overdueInvoicesView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "overdueBillsView_Touched:"))
        incomeDashViewController.paidInvoicesView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "paidBillsView_Touched:"))
        
        originalInvoiceOriginY = incomeDashViewController.openInvoicesView.frame.origin.y
    }

    func resetBillFilterOrigin() {
        UIView.animateWithDuration(0.5) { [unowned self] in
            self.incomeDashViewController.openInvoicesView.frame.origin.y = self.originalInvoiceOriginY
            self.incomeDashViewController.overdueInvoicesView.frame.origin.y = self.originalInvoiceOriginY
            self.incomeDashViewController.paidInvoicesView.frame.origin.y = self.originalInvoiceOriginY
        }
    }
    
    func animateOpenBillInvoiceFilter() {
        UIView.animateWithDuration(0.5) { [unowned self] in
            self.incomeDashViewController.openInvoicesView.frame.origin.y -= 10
        }
    }
    
    func animateOverdueBillFilter() {
        UIView.animateWithDuration(0.5) { [unowned self] in
            self.incomeDashViewController.overdueInvoicesView.frame.origin.y -= 10
        }
    }
    
    func animatePaidBillFilter() {
        UIView.animateWithDuration(0.5) { [unowned self] in
            self.incomeDashViewController.paidInvoicesView.frame.origin.y -= 10
        }
    }

    func openBillsView_Touched(sender:UITapGestureRecognizer) {
        filteredVendors = [Vendor]()
        resetBillFilterOrigin()
        overdueBillsView_IsSelected = false
        paidBillsView_IsSelected = false
        
        if openBillsView_IsSelected {
            incomeStatusType = .None
            for vendor in vendors {
                filteredVendors.append(vendor)
            }
        } else {
            incomeStatusType = .Open
            animateOpenBillInvoiceFilter()
            for vendor in vendors {
                if vendor.getOpenBills().count > 0 {
                    filteredVendors.append(vendor)
                }
            }
        }
        
        openBillsView_IsSelected = !openBillsView_IsSelected
        vendorTableView.reloadData()
    }
    
    func overdueBillsView_Touched(sender:UITapGestureRecognizer) {
        filteredVendors = [Vendor]()
        resetBillFilterOrigin()
        openBillsView_IsSelected = false
        paidBillsView_IsSelected = false
        
        if overdueBillsView_IsSelected {
            incomeStatusType = .None
            for vendor in vendors {
                filteredVendors.append(vendor)
            }
        } else {
            incomeStatusType = .Overdue
            animateOverdueBillFilter()
            for vendor in vendors {
                if vendor.getOverdueBills().count > 0 {
                    filteredVendors.append(vendor)
                }
            }
        }
        
        overdueBillsView_IsSelected = !overdueBillsView_IsSelected
        vendorTableView.reloadData()
    }
    
    func paidBillsView_Touched(sender:UITapGestureRecognizer) {
        filteredVendors = [Vendor]()
        resetBillFilterOrigin()
        openBillsView_IsSelected = false
        overdueBillsView_IsSelected = false
        
        if paidBillsView_IsSelected {
            incomeStatusType = .None
            for vendor in vendors {
                filteredVendors.append(vendor)
            }
        } else {
            incomeStatusType = .Paid
            animatePaidBillFilter()
            for vendor in vendors {
                let compareDate = NSDate().add(componentsDict: ["day":-(30)])!
                for bill in vendor.getPaidBills() {
                    if bill.date > compareDate {
                        filteredVendors.append(vendor)
                        break
                    }
                }
            }
        }
        
        paidBillsView_IsSelected = !paidBillsView_IsSelected
        vendorTableView.reloadData()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredVendors.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: VendorTableViewCell! = tableView.dequeueReusableCellWithIdentifier("VendorTableViewCell") as! VendorTableViewCell
        if(cell == nil) {
            cell = NSBundle.mainBundle().loadNibNamed("VendorTableViewCell", owner: self, options: nil)[0] as! VendorTableViewCell;
        }
        
        cell.name.text = filteredVendors[indexPath.row].name
        cell.phone.text = filteredVendors[indexPath.row].phone
        cell.email.text = filteredVendors[indexPath.row].email
        
        var balance = 0.0
        var count = 0
        var statusText = ""
        
        switch incomeStatusType {
            
        case .None:
            for bill in filteredVendors[indexPath.row].getUnpaidBills() {
                balance += bill.cost
                count++
            }
            statusText = "Unpaid"
        case .Open:
            for bill in filteredVendors[indexPath.row].getOpenBills() {
                balance += bill.cost
                count++
            }
            statusText = "Open"
        case .Overdue:
            for bill in filteredVendors[indexPath.row].getOverdueBills() {
                balance += bill.cost
                count++
            }
            statusText = "Overdue"
        case .Paid:
            let compareDate = NSDate().add(componentsDict: ["day":-(30)])!
            for bill in filteredVendors[indexPath.row].getPaidBills() {
                if bill.date > compareDate {
                    balance += bill.cost
                    count++
                }
            }
            statusText = "Paid"
        }
        
        
        
        cell.balance.text = Global.instance.currencyFormatter.stringFromNumber(balance)!
        
        var invoiceStatus = "-"
        if (count > 0) {
            invoiceStatus = "\(count) \(statusText) bill\(count != 1 ? "s" : "")"
        }
        
        cell.invoiceStatus.text = invoiceStatus
        
        return cell as VendorTableViewCell
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

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

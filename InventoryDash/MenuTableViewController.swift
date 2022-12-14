//
//  MenuTableViewController.swift
//  InventoryDash
//
//  Created by Aboubakar Yaheda on 2015/10/19.
//  Copyright © 2015 Aboubakar Yaheda. All rights reserved.
//

import UIKit

class MenuTableViewController: UITableViewController {

    var selectedMenuItem : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Customize apperance of table view
        tableView.contentInset = UIEdgeInsetsMake(64.0, 0, 0, 0) //
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.clearColor()
        tableView.scrollsToTop = false
        
        // Preserve selection between presentations
        self.clearsSelectionOnViewWillAppear = false
        
        tableView.selectRowAtIndexPath(NSIndexPath(forRow: selectedMenuItem, inSection: 0), animated: false, scrollPosition: .Middle)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return the number of rows
        return 4
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("CELL")
        
        if (cell == nil) {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "CELL")
            cell!.backgroundColor = UIColor.clearColor()
            cell!.textLabel?.textColor = UIColor.darkGrayColor()
            let selectedBackgroundView = UIView(frame: CGRectMake(0, 0, cell!.frame.size.width, cell!.frame.size.height))
            selectedBackgroundView.backgroundColor = UIColor.grayColor().colorWithAlphaComponent(0.2)
            cell!.selectedBackgroundView = selectedBackgroundView
        }
        
        var navigationText = "Dashboard"
        switch indexPath.row {
            
        case 0: navigationText = "Dashboard"
        case 1: navigationText = "Customers"
        case 2: navigationText = "Vendors"
        case 3: navigationText = "Payroll"
            
        default: navigationText = "Menu"
            
        }
        
        cell!.textLabel?.text = navigationText
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 50.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        print("did select row: \(indexPath.row)")
        
        if (indexPath.row == selectedMenuItem) {
            return
        }
        
        selectedMenuItem = indexPath.row
        
        //Present new view controller
        let mainStoryboard: UIStoryboard = UIStoryboard(name: "Main",bundle: nil)
        var destViewController : UIViewController
        switch (indexPath.row) {
        case 0:
            destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("DashboardViewController")
        case 1:
            destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("CustomerViewController")
        case 2:
            destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("VendorViewController")
        case 3:
            destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("PayrollViewController")
        default:
            destViewController = mainStoryboard.instantiateViewControllerWithIdentifier("DashboardViewController")
        }
        
        sideMenuController()?.setContentViewController(destViewController)
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

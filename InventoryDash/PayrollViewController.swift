//
//  PayrollViewController.swift
//  InventoryDash
//
//  Created by Aboubakar Yaheda on 2015/11/26.
//  Copyright © 2015 Aboubakar Yaheda. All rights reserved.
//

import UIKit
import Charts

class PayrollViewController: UIViewController, ENSideMenuDelegate, UITableViewDelegate {

    
    @IBOutlet weak var payrollCost: UILabel!
    @IBOutlet weak var grossPayLabel: UILabel!
    @IBOutlet weak var contributionsLabel: UILabel!
    @IBOutlet weak var headcountLabel: UILabel!
    
    var employees: [Employee]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sideMenuController()?.sideMenu?.delegate = self
        
        employees = InventoryAPI.instance.getEmployees()
        
        var grossPay = 0.0
        var contributions = 0.0
        for employee in employees {
            grossPay += employee.salary
            for contribution in employee.employeeContributions {
                contributions += contribution.cost
            }
        }
        
        grossPayLabel.text = Global.instance.currencyFormatter.stringFromNumber(grossPay)
        contributionsLabel.text = Global.instance.currencyFormatter.stringFromNumber(contributions)
        payrollCost.text = Global.instance.currencyFormatter.stringFromNumber((grossPay + contributions))
        headcountLabel.text = "\(employees.count) Employees"
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return employees.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: EmployeeTableViewCell! = tableView.dequeueReusableCellWithIdentifier("EmployeeTableViewCell") as! EmployeeTableViewCell
        if(cell == nil) {
            cell = NSBundle.mainBundle().loadNibNamed("EmployeeTableViewCell", owner: self, options: nil)[0] as! EmployeeTableViewCell;
        }
        
        cell.name.text = "\(employees[indexPath.row].name) \(employees[indexPath.row].surname)"
        cell.position.text = employees[indexPath.row].position
        cell.salary.text = Global.instance.currencyFormatter.stringFromNumber(employees[indexPath.row].salary)
        cell.phone.text = employees[indexPath.row].mobile
        cell.email.text = employees[indexPath.row].email
        
        return cell as EmployeeTableViewCell
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

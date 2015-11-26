//
//  PayrollViewController.swift
//  InventoryDash
//
//  Created by Aboubakar Yaheda on 2015/11/26.
//  Copyright © 2015 Aboubakar Yaheda. All rights reserved.
//

import UIKit
import Charts

class PayrollViewController: UIViewController, ENSideMenuDelegate {

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sideMenuController()?.sideMenu?.delegate = self
        
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

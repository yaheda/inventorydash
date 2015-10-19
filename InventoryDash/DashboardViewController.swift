//
//  ViewController.swift
//  InventoryDash
//
//  Created by Aboubakar Yaheda on 2015/10/18.
//  Copyright © 2015 Aboubakar Yaheda. All rights reserved.
//

import UIKit

class DashboardViewController: UIViewController, ENSideMenuDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.sideMenuController()?.sideMenu?.delegate = self
    }

    @IBAction func toggleSideMenu(sender: UIBarButtonItem) {
        toggleSideMenuView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


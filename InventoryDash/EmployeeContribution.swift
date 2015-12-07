//
//  EmployeeContribution.swift
//  InventoryDash
//
//  Created by Aboubakar Yaheda on 2015/11/29.
//  Copyright © 2015 Aboubakar Yaheda. All rights reserved.
//

import UIKit

enum EmployeeContributionType: Int {
    case Medical = 1
    case Travel = 2
}

class EmployeeContribution: NSObject {

    var employeeContributionType: EmployeeContributionType
    var cost: Double
    
    init(employeeContributionType: EmployeeContributionType, cost: Double) {
        self.employeeContributionType = employeeContributionType
        self.cost = cost
    }
}

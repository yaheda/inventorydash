//
//  Employee.swift
//  InventoryDash
//
//  Created by Aboubakar Yaheda on 2015/11/29.
//  Copyright © 2015 Aboubakar Yaheda. All rights reserved.
//

import UIKit

class Employee: NSObject {
    
    var id: Int
    var name: String
    var surname: String
    var mobile: String
    var email: String
    var position: String
    var salary: Double
    
    var employeeContributions: [EmployeeContribution]!
    
    init(id: Int, name: String, surname: String, mobile: String, email: String, position: String, salary: Double) {
        self.id = id
        self.name = name
        self.surname = surname
        self.mobile = mobile
        self.email = email
        self.position = position
        self.salary = salary
     
        employeeContributions = [EmployeeContribution]()
    }

}

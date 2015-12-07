//
//  EmployeeTableViewCell.swift
//  InventoryDash
//
//  Created by Aboubakar Yaheda on 2015/11/29.
//  Copyright © 2015 Aboubakar Yaheda. All rights reserved.
//

import UIKit

class EmployeeTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var phone: UILabel!
    @IBOutlet weak var position: UILabel!
    @IBOutlet weak var salary: UILabel!
    @IBOutlet weak var email: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

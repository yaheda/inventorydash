//
//  DashExpenseTableViewCell.swift
//  InventoryDash
//
//  Created by Aboubakar Yaheda on 2015/10/25.
//  Copyright © 2015 Aboubakar Yaheda. All rights reserved.
//

import UIKit

class DashExpenseTableViewCell: UITableViewCell {

    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

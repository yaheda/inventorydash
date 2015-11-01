//
//  LineItem.swift
//  InventoryDash
//
//  Created by Aboubakar Yaheda on 2015/10/30.
//  Copyright © 2015 Aboubakar Yaheda. All rights reserved.
//

import UIKit

class LineItem: NSObject {

    var invoiceId: Int
    var productId: Int
    var quantity: Int
    private var totalPrice: Int
    
    var lineItem: LineItem!
    var product: Product!
    
    init(invoiceId: Int, productId: Int, quantity: Int) {
        self.invoiceId = invoiceId
        self.productId = productId
        self.quantity = quantity
        
        self.totalPrice = 0
    }
    
    func getTotalPrice() -> Double {
        return product.price * Double(quantity)
    }
}

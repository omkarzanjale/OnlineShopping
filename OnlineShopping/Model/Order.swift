//
//  Order.swift
//  OnlineShopping
//
//  Created by Mac on 11/11/21.
//

import Foundation

struct Order {
    var orderId: Int = 0
    var address: String
    var state: String
    var city: String
    var pinCode: Int
    var cashOnDelivery: Bool
    var upiApp: String
    var upiId: String
    var orderDate: String
    var orderTime: String
    var productId: Int
    var customerEmail: String
}

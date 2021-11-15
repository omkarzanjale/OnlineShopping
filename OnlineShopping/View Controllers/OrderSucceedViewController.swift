//
//  OrderSucceedViewController.swift
//  OnlineShopping
//
//  Created by Mac on 12/11/21.
//

import UIKit

class OrderSucceedViewController: UIViewController {
    //
    //MARK: Outlets
    //
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var pinCodeLabel: UILabel!
    
    var productName: String?
    var productPrice: String?
    var address: String?
    var city: String?
    var pinCode: String?
    var orderId: Int?
    var orderTime: String?
    var orderDate: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        setData()
    }
    
    private func setData() {
        nameLabel.text = productName
        priceLabel.text = productPrice
        addressTextView.text = address
        cityLabel.text = city
        pinCodeLabel.text = pinCode
    }
    //
    //MARK: cancelOrderBtnAction
    //
    @IBAction func cancelOrderBtnAction(_ sender: Any) {
        guard let orderDate = orderDate else {return}
        guard let orderTime = orderTime else {return}
        let alert = UIAlertController(title: "Warning", message: "You want to cancel this order?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Cancel Order", style: .default, handler: { (_) in
            DatabaseHelper().cancelOrder(orderDate: orderDate, orderTime: orderTime) { (_, _) in
                self.navigationController?.popToRootViewController(animated: true)
            }
        }))
        present(alert, animated: true, completion: nil)
    }
    //
    //MARK: homeBtnAction
    //
    @IBAction func homeBtnAction(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
}

//
//  OrderViewController.swift
//  OnlineShopping
//
//  Created by Mac on 11/11/21.
//

import UIKit

class OrderViewController: UIViewController {
    //
    //MARK: Outlets
    //
    @IBOutlet weak var productTitleLabel: UILabel!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var stateTextField: UITextField!
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var pinCodeTextField: UITextField!
    @IBOutlet weak var paymentSwitch: UISwitch!
    @IBOutlet weak var upiIdTextField: UITextField!
    @IBOutlet weak var upiAppTextField: UITextField!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var upiAppLabel: UILabel!
    
    var product: Product?
    var userEmail: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Order"
        guard let product = product else {return}
        priceLabel.text = String(product.price)
        productTitleLabel.text = product.title
    }
    
    private func showAlert(title: String, message: String, navigate: Bool = false) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func validateTextfields(isCod:Bool) -> Bool {
        guard let address = addressTextField.text else {return false}
        guard let state = stateTextField.text else {return false}
        guard let city = cityTextField.text else {return false}
        guard let pinCode = pinCodeTextField.text else {return false}
        guard let upiApp = upiAppTextField.text else {return false}
        guard let upiId = upiIdTextField.text else {return false}
        if isCod {
            if address.isEmpty==true||state.isEmpty==true||city.isEmpty==true||pinCode.isEmpty==true {
                showAlert(title: "Warning", message: "Please enter all fields!")
                return false
            } else {
                if let _ = Int(pinCode) {
                    return true
                } else {
                    showAlert(title: "Warning", message: "Invalid Pin Code!")
                    return false
                }
            }
        } else {
            if address.isEmpty==true||state.isEmpty==true||city.isEmpty==true||pinCode.isEmpty==true||upiApp.isEmpty==true||upiId.isEmpty==true {
                showAlert(title: "Warning", message: "Please enter all fields!")
                return false
            } else {
                if let _ = Int(pinCode) {
                    return true
                } else {
                    showAlert(title: "Warning", message: "Invalid Pin Code!")
                    return false
                }
            }
        }
    }
    //
    //MARK: paymentSwitchAction
    //
    @IBAction func paymentSwitchAction(_ sender: Any) {
        if paymentSwitch.isOn {
            upiAppLabel.text = "Select your UPI App"
            upiIdTextField.isHidden = false
            upiAppTextField.isHidden = false
            
        } else {
            upiAppLabel.text = "Cash On Delevery"
            upiIdTextField.isHidden = true
            upiAppTextField.isHidden = true
        }
    }
    
    private func getTime() ->(orderDate: String, orderTime: String)? {
        let todaysDate = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute,.second,.nanosecond], from: todaysDate)
        if let hour = components.hour {
            if let min = components.minute {
                if let sec = components.second {
                    if let nanoSec = components.nanosecond {
                        let hourStr = String(hour)
                        let minStr = String(min)
                        let secStr = String(sec)
                        let nanoSecStr = String(nanoSec)
                        let orderTime = hourStr+":"+minStr+":"+secStr+":"+nanoSecStr
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd-MM-yyyy"
                        let orderDate = dateFormatter.string(from: todaysDate)
                        return (orderDate: orderDate, orderTime: orderTime)
                    }
                    
                }
            }
        }
        return nil
    }
    
    private func placeOrder(isCod: Bool) -> (orderSucceed: Bool,orderDate: String, orderTime: String)? {
        var orderPlaced = false
        let databaseObj = DatabaseHelper()
        guard let orderTimeDetails = getTime() else {return nil}
        let orderDate = orderTimeDetails.orderDate
        let orderTime = orderTimeDetails.orderTime
        guard let address = addressTextField.text else {return nil}
        guard let state = stateTextField.text else {return nil}
        guard let city = cityTextField.text else {return nil}
        guard let pinCode = pinCodeTextField.text else {return nil}
        guard let upiApp = upiAppTextField.text else {return nil}
        guard let upiId = upiIdTextField.text else {return nil}
        guard let product = product else {return nil}
        guard let userEmail = userEmail else {return nil}
        if isCod {
            let order = Order(address: address, state: state, city: city, pinCode: Int(pinCode)!, cashOnDelivery: true, upiApp: "-", upiId: "-", orderDate: orderDate, orderTime: orderTime, productId: product.id, customerEmail: userEmail)
            databaseObj.placeOrder(order: order) { (_, _) in
                orderPlaced = true
            } failure: { (title, message) in
                showAlert(title: title, message: message)
            }
            return (orderPlaced,orderDate,orderTime)
        } else {
            let order = Order(address: address, state: state, city: city, pinCode: Int(pinCode)!, cashOnDelivery: false, upiApp: upiApp, upiId: upiId, orderDate: orderDate, orderTime: orderTime, productId: product.id, customerEmail: userEmail)
            databaseObj.placeOrder(order: order) { (_, _) in
                orderPlaced = true
            } failure: { (title, message) in
                showAlert(title: title, message: message)
            }
            return (orderPlaced,orderDate,orderTime)
        }
    }
    
    private func navigateToOrderSucceedVC(orderDate: String, orderTime: String) {
        if let orderSucceedViewControllerObj = storyboard?.instantiateViewController(withIdentifier: "OrderSucceedViewController") as? OrderSucceedViewController {
            orderSucceedViewControllerObj.productName = product?.title
            orderSucceedViewControllerObj.productPrice = String(product!.price)
            orderSucceedViewControllerObj.address = addressTextField.text
            orderSucceedViewControllerObj.city = cityTextField.text
            orderSucceedViewControllerObj.pinCode =  pinCodeTextField.text
            orderSucceedViewControllerObj.orderTime = orderTime
            orderSucceedViewControllerObj.orderDate = orderDate
            navigationController?.pushViewController(orderSucceedViewControllerObj, animated: true)
        } else {
            print("Unable to find OrderSucceedViewController in storyboard!")
        }
    }
    
    private func confirmOrderAlert(isCod: Bool) {
        let alert = UIAlertController(title: "Confirm", message: "You want to place Order", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Order", style: .default, handler: { (_) in
            if isCod{
                guard let orderStatus = self.placeOrder(isCod: true) else {return}
                if orderStatus.orderSucceed {
                    self.navigateToOrderSucceedVC(orderDate: orderStatus.orderDate, orderTime: orderStatus.orderTime)
                }
            } else {
                guard let orderStatus = self.placeOrder(isCod: false) else {return}
                if orderStatus.orderSucceed {
                    self.navigateToOrderSucceedVC(orderDate: orderStatus.orderDate, orderTime: orderStatus.orderTime)
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    //
    //MARK: proceedBtnAction
    //
    @IBAction func proceedBtnAction(_ sender: Any) {
        if paymentSwitch.isOn {
            if validateTextfields(isCod: false) {
                confirmOrderAlert(isCod: false)
            }
        } else {
            if validateTextfields(isCod: true) {
                confirmOrderAlert(isCod: true)
            }
        }
    }
}

//
//  CartViewController.swift
//  OnlineShopping
//
//  Created by Mac on 10/11/21.
//

import UIKit

class CartViewController: UIViewController {
    //
    //MARK: Outlets
    //
    @IBOutlet weak var cartTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noInternetImg: UIImageView!
    @IBOutlet weak var emptyCartLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    var userEmail: String?
    var cartProducts = [Product]()
    var cartProductsId = [Int]()
    var cartIds = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.backgroundColor = .blue
        self.activityIndicator.startAnimating()
        self.cartTableView.isHidden = true
        self.cartTableView.tableFooterView = UIView()
        self.noInternetImg.isHidden = true
        self.emptyCartLabel.isHidden = true
        if let userEmail = userEmail {
            self.getCartProductsId(userEmail: userEmail)
            if cartProductsId.isEmpty == false {
                apiCall()
            }else {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidesWhenStopped = true
                self.emptyCartLabel.isHidden = false
            }
        }
        self.cartTableView.register(UINib(nibName: "ProductTableViewCell", bundle: Bundle.main), forCellReuseIdentifier: "ProductTableViewCell")
    }
    
    private func getCartProductsId(userEmail: String) {
        if let cartData = DatabaseHelper().getCartDataFor(userEmail: userEmail) {
            self.cartProductsId = cartData.productsId
            self.cartIds = cartData.cartsId
        } else {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.hidesWhenStopped = true
            self.emptyCartLabel.isHidden = false
        }
    }
    
    private func getCartProductsDetails(products: [Product]) {
        for i in 0..<products.count {
            for j in 0..<cartProductsId.count {
                if products[i].id == cartProductsId[j] {
                    self.cartProducts.append(products[i])
                }
            }
        }
    }
    //
    //MARK: apiCall
    //
    private func apiCall() {
        APIData().getProductsFromAPI {
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidesWhenStopped = true
                self.noInternetImg.isHidden = false
            }
        } successClosure: { (products) in
            self.getCartProductsDetails(products: products)
            DispatchQueue.main.async {
                self.cartTableView.isHidden = false
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidesWhenStopped = true
                self.noInternetImg.isHidden = true
                self.emptyCartLabel.isHidden = true
                self.cartTableView.reloadData()
            }
        }
    }
}
//
//MARK: UITableViewDataSource
//
extension CartViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cartProducts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cartProductCell = cartTableView.dequeueReusableCell(withIdentifier: "ProductTableViewCell", for: indexPath) as? ProductTableViewCell {
            let product = cartProducts[indexPath.row]
            cartProductCell.productImage.downloaded(from: product.image)
            cartProductCell.productImage.layer.cornerRadius = 20
            cartProductCell.productName.text = product.title
            cartProductCell.productPrice.text = String(product.price)
            return cartProductCell
        } else {
            return UITableViewCell()
        }
    }
}
//
//MARK: UITableViewDelegate
//
extension CartViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let product = cartProducts[indexPath.row]
        if let productDetailsViewControllerObj = storyboard?.instantiateViewController(withIdentifier: "ProductDetailsViewController") as? ProductDetailsViewController {
            productDetailsViewControllerObj.product = product
            productDetailsViewControllerObj.userEmail = userEmail
            productDetailsViewControllerObj.isFromCart = true
            navigationController?.pushViewController(productDetailsViewControllerObj, animated: true)
        } else {
            print("Unable to find ProductDetailsViewController in storyboard!!!")
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = UIContextualAction(style: .destructive, title: "Remove") { (_, _, _) in
            let cartId = self.cartIds[indexPath.row]
            DatabaseHelper().deleteCartProduct(cartId: cartId) { (_, _) in
                self.cartProducts.remove(at: indexPath.row)
                self.cartIds.remove(at: indexPath.row)
                tableView.reloadData()
            } failure: { (title, message) in
                let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        edit.image = UIImage(systemName: "trash")
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [edit])
        return swipeConfiguration
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let buy = UIContextualAction(style: .normal, title: "Buy") { (_, _, _) in
            let product = self.cartProducts[indexPath.row]
            if let orderViewControllerObj = self.storyboard?.instantiateViewController(withIdentifier: "OrderViewController") as? OrderViewController {
                orderViewControllerObj.userEmail = self.userEmail
                orderViewControllerObj.product = product
                self.navigationController?.pushViewController(orderViewControllerObj, animated: true)
            } else {print("OrderViewController not found in storyboard!")}
        }
        buy.backgroundColor = .systemBlue
        buy.image = UIImage(systemName: "arrow.forward.circle")
        let swipeConfiguration = UISwipeActionsConfiguration(actions: [buy])
        return swipeConfiguration
    }
}

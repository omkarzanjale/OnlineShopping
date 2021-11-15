//
//  ProductDetailsViewController.swift
//  OnlineShopping
//
//  Created by Mac on 09/11/21.
//

import UIKit

class ProductDetailsViewController: UIViewController {
    //
    //MARK: Outlets
    //
    @IBOutlet weak var productImage: UIImageView!
    @IBOutlet weak var productName: UITextView!
    @IBOutlet weak var productDescription: UITextView!
    @IBOutlet weak var productPrice: UILabel!
    @IBOutlet weak var productCount: UILabel!
    @IBOutlet weak var addToCart: UIButton!
    @IBOutlet weak var firstStar: UIImageView!
    @IBOutlet weak var secondStar: UIImageView!
    @IBOutlet weak var thirdStar: UIImageView!
    @IBOutlet weak var forthStar: UIImageView!
    @IBOutlet weak var fifthStar: UIImageView!
    
    let filledStar = UIImage(systemName: "star.fill")
    let halfFilledStar = UIImage(systemName: "star.fill.left")
    let emptyStar = UIImage(systemName: "Star")
    var product: Product?
    var userEmail: String?
    var isFromCart: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Product details"
        navigationController?.isNavigationBarHidden = false
        navigationController?.navigationBar.backgroundColor = .blue
        productName.showsVerticalScrollIndicator = false
        productName.isEditable = false
        productDescription.showsVerticalScrollIndicator = false
        productDescription.isEditable = false
        if isFromCart {
            addToCart.isHidden = true
        }
        setValues()
        
    }
    
    private func setRating(_ product: Product){
        let rate = product.rating.rate
        if rate>0 && rate<=0.5 {
            firstStar.image = halfFilledStar
        } else if rate>0.5 && rate<=1 {
            firstStar.image = filledStar
        } else if rate>1 && rate<=1.5 {
            firstStar.image = filledStar
            secondStar.image = halfFilledStar
        } else if rate>1.5 && rate<=2 {
            firstStar.image = filledStar
            secondStar.image = filledStar
        } else if rate>2 && rate<=2.5 {
            firstStar.image = filledStar
            secondStar.image = filledStar
            thirdStar.image = halfFilledStar
        } else if rate>2.5 && rate<=3 {
            firstStar.image = filledStar
            secondStar.image = filledStar
            thirdStar.image = filledStar
        } else if rate>3 && rate<=3.5 {
            firstStar.image = filledStar
            secondStar.image = filledStar
            thirdStar.image = filledStar
            forthStar.image = halfFilledStar
        } else if rate>3.5 && rate<=4 {
            firstStar.image = filledStar
            secondStar.image = filledStar
            thirdStar.image = filledStar
            forthStar.image = filledStar
        } else if rate>4 && rate<=4.5 {
            firstStar.image = filledStar
            secondStar.image = filledStar
            thirdStar.image = filledStar
            forthStar.image = filledStar
            forthStar.image = halfFilledStar
        } else {
            firstStar.image = filledStar
            secondStar.image = filledStar
            thirdStar.image = filledStar
            forthStar.image = filledStar
            forthStar.image = filledStar
        }
    }
    
    private func setValues() {
        guard let product = product else { return }
        do{
            guard let imgURL = URL(string: product.image) else { return }
            let imgData = try Data(contentsOf: imgURL)
            productImage.image = UIImage(data: imgData)
        } catch {
            print("Error :\(error.localizedDescription)")
        }
        productName.text = product.title
        productDescription.text = product.description
        productPrice.text = String(product.price)
        productCount.text = String(product.rating.count)
        setRating(product)
    }
    
    private func navigateToCart() {
        if let cartViewControllerObj = storyboard?.instantiateViewController(withIdentifier: "CartViewController") as? CartViewController {
            cartViewControllerObj.userEmail = userEmail
            navigationController?.pushViewController(cartViewControllerObj, animated: true)
        } else {
            print("Unable to locate CartViewController in storyboard!")
        }
    }
    
    private func showAlert(title: String, message: String, goToCart: Bool = false) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if goToCart {
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Cart", style: .default , handler: { (_) in
                self.navigateToCart()
            }))
        } else {
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        }
        present(alert, animated: true, completion: nil)
    }
    
    private func addProductToCart(ProductId: Int, userEmail: String) {
        DatabaseHelper().addToCart(productId: ProductId, userEmail: userEmail) { (title, message) in
            showAlert(title: title, message: message,goToCart: true)
        } failure: { (title, message) in
            showAlert(title: title, message: message)
        }
    }
    //
    //MARK: addToCartBtnAction
    //
    @IBAction func addToCartBtnAction(_ sender: Any) {
        if let userEmail = userEmail {
            guard let product = product else {return}
            addProductToCart(ProductId: product.id, userEmail: userEmail)
        } else {
            showAlert(title: "Warning", message: "Login first & try again.")
        }
    }
    //
    //MARK: buyBtnAction
    //
    @IBAction func buyBtnAction(_ sender: Any) {
        if let userEmail = userEmail {
            guard let product = product else {return}
            if let orderViewControllerObj = storyboard?.instantiateViewController(withIdentifier: "OrderViewController") as? OrderViewController {
                orderViewControllerObj.product = product
                orderViewControllerObj.userEmail = userEmail
                navigationController?.pushViewController(orderViewControllerObj, animated: true)
            } else {
                print("Unable to find OrderViewController in storyboard!")
            }
        } else {
            showAlert(title: "Warning", message: "Login first & try again.")
        }
    }
}

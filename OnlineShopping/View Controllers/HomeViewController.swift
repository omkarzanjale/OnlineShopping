//
//  ViewController.swift
//  OnlineShopping
//
//  Created by Mac on 30/09/21.
//

import UIKit

class HomeViewController: UIViewController {
    //
    //MARK: Outlets
    //
    @IBOutlet weak var productSearchBar: UISearchBar!
    @IBOutlet weak var categoriesSeg: UISegmentedControl!
    @IBOutlet weak var allProductsCollectionView: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var noInternetImgView: UIImageView!
    @IBOutlet weak var refreshBtn: UIButton!
    
    @IBOutlet weak var MensView: UIView!
    @IBOutlet weak var womensView: UIView!
    @IBOutlet weak var jewelleryView: UIView!
    @IBOutlet weak var electronicsView: UIView!
    
    var allProducts = [Product]()
    var searchedText: String = ""
    static var isSignIn: Bool = false
    static var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addLayout()
        noInternetImgView.isHidden = true
        refreshBtn.isHidden = true
        allProductsCollectionView.isHidden = true
        activityIndicator.startAnimating()
        apiCall()
        categoriesSeg.selectedSegmentIndex = 0
        categorySegAction(UISegmentedControl())
        productSearchBar.placeholder = "Search with similar Word"
        navigationController?.isNavigationBarHidden = true
    }
    //
    //MARK: APICall
    //
    private func apiCall(){
        APIData().getProductsFromAPI {
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidesWhenStopped = true
                self.noInternetImgView.isHidden = false
                self.refreshBtn.isHidden = false
            }
        } successClosure: { (products) in
            if self.searchedText.isEmpty {
                self.allProducts = products
            } else {
                self.allProducts.removeAll()
                for product in products {
                    let title = product.title.components(separatedBy: " ")
                    for var i in 0..<title.count{
                        if title[i].lowercased() == self.searchedText{
                            self.allProducts.append(product)
                        }
                        i+=1
                    }
                    
                }
            }
            DispatchQueue.main.async {
                self.allProductsCollectionView.isHidden = false
                self.allProductsCollectionView.reloadData()
                self.activityIndicator.stopAnimating()
                self.activityIndicator.hidesWhenStopped = true
                self.noInternetImgView.isHidden = true
                self.refreshBtn.isHidden = true
            }
        }
    }
    
    private func addLayout() {
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.minimumLineSpacing = 10
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .vertical
        allProductsCollectionView?.collectionViewLayout = layout
    }
    //
    //MARK: Segue Action
    //
    @IBAction func categorySegAction(_ sender: Any) {
        MensView.isHidden = true
        womensView.isHidden = true
        jewelleryView.isHidden = true
        electronicsView.isHidden = true
        switch categoriesSeg.selectedSegmentIndex {
        case 0:
            MensView.isHidden = false
        case 1:
            womensView.isHidden = false
        case 2:
            jewelleryView.isHidden = false
        case 3:
            electronicsView.isHidden = false
        default:
            break
        }
    }
    //
    //MARK: refreshBtnAction
    //
    @IBAction func refreshBtnAction(_ sender: Any) {
        noInternetImgView.isHidden = true
        refreshBtn.isHidden = true
        activityIndicator.startAnimating()
        apiCall()
        categoriesSeg.selectedSegmentIndex = 0
        categorySegAction(UISegmentedControl())
    }
    //
    //MARK: accountToolBarBtnAction
    //
    @IBAction func accountToolBarBtnAction(_ sender: Any) {
        guard let userProfileViewControllerObj = storyboard?.instantiateViewController(withIdentifier: "UserProfileViewController") as? UserProfileViewController else {
            print("Unable to find UserProfileViewController in storyboard!!!")
            return
        }
        if HomeViewController.isSignIn {
            userProfileViewControllerObj.user = HomeViewController.user
                navigationController?.pushViewController(userProfileViewControllerObj, animated: true)
        } else {
            if let signInViewControllerObj = storyboard?.instantiateViewController(withIdentifier: "SignInViewController") as? SignInViewController {
                signInViewControllerObj.delegate = self
                navigationController?.pushViewController(signInViewControllerObj, animated: true)
            } else {
                print("Unable to find SignInViewController in storyboard!!!")
            }
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    //
    //MARK: cartToolBarBtnAction
    //
    @IBAction func cartToolBarBtnAction(_ sender: Any) {
        if HomeViewController.isSignIn {
            if let cartViewControllerObj = storyboard?.instantiateViewController(withIdentifier: "CartViewController") as? CartViewController {
                cartViewControllerObj.userEmail = HomeViewController.user?.email
                navigationController?.pushViewController(cartViewControllerObj, animated: true)
            } else {
                print("Unable to locate CartViewController in storyboard!")
            }
        } else {
            showAlert(title: "Warning", message: "Login First")
        }
    }
    
    private func dismissKeyboard() {
        productSearchBar.resignFirstResponder()
    }
    
    fileprivate func preSearch() {
        self.allProductsCollectionView.isHidden = true
        self.noInternetImgView.isHidden = true
        self.activityIndicator.startAnimating()
    }
}
//
//MARK: UICollectionViewDataSource
//
extension HomeViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        allProducts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let allProduct = collectionView.dequeueReusableCell(withReuseIdentifier: "AllProductsCell", for: indexPath) as? AllProductsCell {
            let product = allProducts[indexPath.row]
            allProduct.productImage.downloaded(from: product.image)
            allProduct.productImage.layer.cornerRadius = 20
            allProduct.productName.text = product.title
            allProduct.productPrice.text = String(product.price)
            return allProduct
        } else {
            return UICollectionViewCell()
        }
    }
}
//
//MARK: UICollectionViewDelegateFlowLayout
//
extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width/2-15
        let height = CGFloat(200)
        return CGSize(width: width, height: height)
    }
}
//
//MARK: UICollectionViewDelegate
//
extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let product = allProducts[indexPath.row]
        if let productDetailsViewControllerObj = storyboard?.instantiateViewController(withIdentifier: "ProductDetailsViewController") as? ProductDetailsViewController {
            productDetailsViewControllerObj.product = product
            productDetailsViewControllerObj.userEmail = HomeViewController.user?.email
            navigationController?.pushViewController(productDetailsViewControllerObj, animated: true)
        } else {
            print("Unable to find ProductDetailsViewController in storyboard!!!")
        }
    }
}
//
//MARK: UISearch Bar Delegate
//
extension HomeViewController: UISearchBarDelegate {
     
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        dismissKeyboard()
        guard let searchedText = searchBar.text else { return }
        if searchedText.isEmpty == false {
            self.searchedText = searchedText.lowercased()
            preSearch()
            apiCall()
        }else{
            self.searchedText = ""
            preSearch()
            apiCall()
        }
    }
}
//
//MARK: Download Image
//
extension UIImageView {
    func downloaded(from url: URL, contentMode mode: ContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }.resume()
    }
    func downloaded(from link: String, contentMode mode: ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
//
//MARK: SignInViewControllerProtocol
//
extension HomeViewController: SignInViewControllerProtocol {
    func updatedInfo(user: User) {
        HomeViewController.user = user
        HomeViewController.isSignIn = true
    }
}

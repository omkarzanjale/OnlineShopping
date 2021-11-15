//
//  FurnituresViewController.swift
//  OnlineShopping
//
//  Created by Mac on 05/11/21.
//

import UIKit

class WomensCategoryViewController: UIViewController {

    @IBOutlet weak var womensFashionCollectionView: UICollectionView!
    
    var womensFashionProducts = [Product]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addLayout()
        womensFashionCollectionView.isHidden = true
        APICall()
        let nibFile = UINib(nibName: "CategoriesCell", bundle: nil)
        self.womensFashionCollectionView.register(nibFile, forCellWithReuseIdentifier: "CategoriesCell")
    }
    
    private func addLayout() {
        let layout : UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.scrollDirection = .horizontal
        self.womensFashionCollectionView.collectionViewLayout = layout
    }
    //
    //MARK: API Call
    //
    private func APICall() {
        APIData().getProductsFromAPI {} successClosure: { (products) in
            for product in products {
                if product.category == "women's clothing" {
                    self.womensFashionProducts.append(product)
                }
            }
            DispatchQueue.main.async {
                self.womensFashionCollectionView.isHidden = false
                self.womensFashionCollectionView.reloadData()
            }
        }
    }
}
//
//MARK: UICollectionViewDataSource
//
extension WomensCategoryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        womensFashionProducts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let womenFashionCell = womensFashionCollectionView.dequeueReusableCell(withReuseIdentifier: "CategoriesCell", for: indexPath) as? CategoriesCell {
            let product = womensFashionProducts[indexPath.row]
            womenFashionCell.productImg.downloaded(from: product.image)
            womenFashionCell.productName.text = product.title
            womenFashionCell.productPrice.text = String(product.price)
            return womenFashionCell
        } else {
            return UICollectionViewCell()
        }
    }
}
//
//MARK: UICollectionViewDelegateFlowLayout
//
extension WomensCategoryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = view.frame.height-20
        let width = view.frame.width-20
        return CGSize(width: width, height: height)
    }
}
//
//MARK: UICollectionViewDelegate
//
extension WomensCategoryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let productDetailsViewControllerObj = storyboard?.instantiateViewController(withIdentifier: "ProductDetailsViewController") as? ProductDetailsViewController {
            let product = womensFashionProducts[indexPath.row]
            productDetailsViewControllerObj.product = product
            productDetailsViewControllerObj.userEmail = HomeViewController.user?.email
            navigationController?.pushViewController(productDetailsViewControllerObj, animated: true)
        } else {
            print("ProductDetailsViewController not found in storyboard!!!")
        }
    }
}

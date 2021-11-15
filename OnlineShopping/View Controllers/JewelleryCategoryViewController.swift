//
//  FashionsViewController.swift
//  OnlineShopping
//
//  Created by Mac on 05/11/21.
//

import UIKit

class JewelleryCategoryViewController: UIViewController {

    @IBOutlet weak var jewelleryCollectionView: UICollectionView!
    
    var jewelleryProducts = [Product]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addLayout()
        self.jewelleryCollectionView.isHidden = true
        APICall()
        self.jewelleryCollectionView.register(UINib(nibName: "CategoriesCell", bundle: Bundle.main), forCellWithReuseIdentifier: "CategoriesCell")
    }
    
    private func addLayout() {
        let layout  = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.scrollDirection = .horizontal
        self.jewelleryCollectionView.collectionViewLayout = layout
    }
    //
    //MARK: API Call
    //
    private func APICall() {
        APIData().getProductsFromAPI {
        } successClosure: { (products) in
            for product in products {
                if product.category == "jewelery" {
                    self.jewelleryProducts.append(product)
                }
            }
            DispatchQueue.main.async {
                self.jewelleryCollectionView.isHidden = false
                self.jewelleryCollectionView.reloadData()
            }
        }
    }
}
//
//MARK: UICollectionViewDataSource
//
extension JewelleryCategoryViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        jewelleryProducts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let jewelleryCell = jewelleryCollectionView.dequeueReusableCell(withReuseIdentifier: "CategoriesCell", for: indexPath) as? CategoriesCell {
            let product = jewelleryProducts[indexPath.row]
            jewelleryCell.productImg.downloaded(from: product.image)
            jewelleryCell.productName.text = product.title
            jewelleryCell.productPrice.text = String(product.price)
            return jewelleryCell
        } else {
            return UICollectionViewCell()
        }
    }
}
//
//MARK: UICollectionViewDelegateFlowLayout
//
extension JewelleryCategoryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width-20
        let height = view.frame.height-20
        return CGSize(width: width, height: height)
    }
}
//
//MARK: UICollectionViewDelegate
//
extension JewelleryCategoryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let productDetailsViewControllerObj = storyboard?.instantiateViewController(withIdentifier: "ProductDetailsViewController") as? ProductDetailsViewController {
            let product = jewelleryProducts[indexPath.row]
            productDetailsViewControllerObj.product = product
            productDetailsViewControllerObj.userEmail = HomeViewController.user?.email
            navigationController?.pushViewController(productDetailsViewControllerObj, animated: true)
        } else {
            print("ProductDetailsViewController not found in storyboard!!!")
        }
    }
}

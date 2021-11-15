//
//  ElectronicsViewController.swift
//  OnlineShopping
//
//  Created by Mac on 05/11/21.
//

import UIKit

class ElectronicsCategoryViewController: UIViewController {

    @IBOutlet weak var electronicsCollectionView: UICollectionView!
    
    var electronicProducts = [Product]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addLayout()
        self.electronicsCollectionView.isHidden = true
        APICall()
        self.electronicsCollectionView.register(UINib(nibName: "CategoriesCell", bundle: Bundle.main), forCellWithReuseIdentifier: "CategoriesCell")
    }
    
    private func addLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.scrollDirection = .horizontal
        self.electronicsCollectionView.collectionViewLayout = layout
    }
    
    private func APICall() {
        APIData().getProductsFromAPI {
            
        } successClosure: { (products) in
            for product in products {
                if product.category == "electronics" {
                    self.electronicProducts.append(product)
                }
            }
            DispatchQueue.main.async {
                self.electronicsCollectionView.isHidden = false
                self.electronicsCollectionView.reloadData()
            }
        }
    }
}
//
//MARK: UICollectionViewDataSource
//
extension ElectronicsCategoryViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        electronicProducts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let electronicsCell = electronicsCollectionView.dequeueReusableCell(withReuseIdentifier: "CategoriesCell", for: indexPath) as? CategoriesCell {
            let product = electronicProducts[indexPath.row]
            electronicsCell.productImg.downloaded(from: product.image)
            electronicsCell.productName.text = product.title
            electronicsCell.productPrice.text = String(product.price)
            return electronicsCell
        } else {
            return UICollectionViewCell()
        }
    }
}
//
//MARK: UICollectionViewDelegateFlowLayout
//
extension ElectronicsCategoryViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (view.frame.width-20), height: (view.frame.height-20))
    }
}
//
//MARK: UICollectionViewDelegate
//
extension ElectronicsCategoryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let productDetailsViewControllerObj = storyboard?.instantiateViewController(withIdentifier: "ProductDetailsViewController") as? ProductDetailsViewController {
            let product = electronicProducts[indexPath.row]
            productDetailsViewControllerObj.product = product
            productDetailsViewControllerObj.userEmail = HomeViewController.user?.email
            navigationController?.pushViewController(productDetailsViewControllerObj, animated: true)
        } else {
            print("ProductDetailsViewController not found in storyboard!!!")
        }
    }
}


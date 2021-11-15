//
//  MobilesViewController.swift
//  OnlineShopping
//
//  Created by Mac on 05/11/21.
//

import UIKit

class MensCategoryViewController: UIViewController {
    //
    //MARK: Outlets
    //
    @IBOutlet weak var mensFashionCollectionView: UICollectionView!
    
    static var userEmail: String?
    var mensFashionProducts = [Product]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addLayout()
        mensFashionCollectionView.isHidden = true
        APICall()
        let nibFile = UINib(nibName: "CategoriesCell", bundle: nil)
        self.mensFashionCollectionView.register(nibFile, forCellWithReuseIdentifier: "CategoriesCell")
    }
    //
    //MARK: APICall
    //
    private func APICall(){
        APIData().getProductsFromAPI {} successClosure: { (products) in
            for product in products {
                if product.category == "men's clothing" {
                    self.mensFashionProducts.append(product)
                }
            }
            DispatchQueue.main.async {
                self.mensFashionCollectionView.isHidden = false
                self.mensFashionCollectionView.reloadData()
            }
        }
    }
    
    private func addLayout(){
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        layout.scrollDirection = .horizontal
        mensFashionCollectionView.collectionViewLayout = layout
    }
}
//
//MARK: UICollectionViewDataSource
//
extension MensCategoryViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        mensFashionProducts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let mensFashionCell = mensFashionCollectionView.dequeueReusableCell(withReuseIdentifier: "CategoriesCell", for: indexPath) as? CategoriesCell {
            let product = mensFashionProducts[indexPath.row]
            mensFashionCell.productName.text = product.title
            mensFashionCell.productPrice.text = String(product.price)
            mensFashionCell.productImg.downloaded(from: product.image)
            return mensFashionCell
        } else {
            return UICollectionViewCell()
        }
    }
}
//
//MARK: UICollectionViewDelegateFlowLayout
//
extension MensCategoryViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = view.frame.width-20
        let height = view.frame.height-20
        return CGSize(width: width, height: height)
    }
}
//
//MARK: UICollectionViewDelegate
//
extension MensCategoryViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let productDetailsViewControllerObj = storyboard?.instantiateViewController(withIdentifier: "ProductDetailsViewController") as? ProductDetailsViewController {
            let product = mensFashionProducts[indexPath.row]
            productDetailsViewControllerObj.product = product
            productDetailsViewControllerObj.userEmail = HomeViewController.user?.email
            navigationController?.pushViewController(productDetailsViewControllerObj, animated: true)
        } else {
            print("ProductDetailsViewController not found in storyboard!!!")
        }
    }
}

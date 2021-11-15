//
//  APIData.swift
//  OnlineShopping
//
//  Created by Mac on 06/11/21.
//

import Foundation

class APIData {
    
    private let urlString = "https://fakestoreapi.com/products"
    
    typealias successed = (_ products: [Product])->()
    typealias failured = ()->()
    
    func getProductsFromAPI(failureClosure: @escaping failured, successClosure: @escaping successed) {
        var productsArray = [Product]()
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let dataTask = session.dataTask(with: url) { (dataFromServer, response, error) in
                guard let data = dataFromServer else {
                    print("Error while getting data From server!!!")
                    failureClosure()
                    return
                }
                do {
                    let products = try JSONDecoder().decode([Product].self, from: data)
                    productsArray = products
                    successClosure(productsArray)
                }catch {
                    print("Error : \(error.localizedDescription)")
                }
            }
            dataTask.resume()
        } else {
            print("Invalid URL!!!")
        }
    }
}

//
//  UserProfileViewController.swift
//  OnlineShopping
//
//  Created by Mac on 10/11/21.
//

import UIKit

class UserProfileViewController: UIViewController {
    //
    //MARK: Outlets
    //
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var contactLabel: UILabel!
    
    var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Home", style: .plain, target: self, action: #selector(navigationBackHomeBtn))
        self.navigationItem.leftBarButtonItem = newBackButton
        setData()
    }
    
    @objc func navigationBackHomeBtn() {
        navigationController?.popToRootViewController(animated: true)
    }
    
    private func setData(){
        guard let user = user else {return}
        nameLabel.text = user.name
        emailLabel.text = user.email
        contactLabel.text = user.contact
    }
    //
    //MARK: myOrdersBtnAction
    //
    @IBAction func myOrdersBtnAction(_ sender: Any) {
        
    }
    //
    //MARK: myCartBtnAction
    //
    @IBAction func myCartBtnAction(_ sender: Any) {
        if let cartViewControllerObj = storyboard?.instantiateViewController(withIdentifier: "CartViewController") as? CartViewController {
            cartViewControllerObj.userEmail = user?.email
            navigationController?.pushViewController(cartViewControllerObj, animated: true)
        } else {
            print("Unable to locate CartViewController in storyboard!")
        }
    }
    //
    //MARK: editProfileBtnAction
    //
    @IBAction func editProfileBtnAction(_ sender: Any) {
        
    }
    //
    //MARK: signOutBtnAction
    //
    @IBAction func signOutBtnAction(_ sender: Any) {
        HomeViewController.isSignIn = false
        HomeViewController.user = nil
        navigationController?.popToRootViewController(animated: true)
    }
    //
    //MARK: homeBtnAction
    //
    @IBAction func homeBtnAction(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
}

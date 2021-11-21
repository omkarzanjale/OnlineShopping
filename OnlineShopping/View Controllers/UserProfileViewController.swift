//
//  UserProfileViewController.swift
//  OnlineShopping
//
//  Created by Mac on 10/11/21.
//

import UIKit
import GoogleSignIn

class UserProfileViewController: UIViewController {
    //
    //MARK: Outlets
    //
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var contactTextLabel: UILabel!
    
    var user: User?
    var isGoogleAccount: Bool = false
    
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
        if isGoogleAccount {
            contactTextLabel.isHidden = true
            contactLabel.isHidden = true
        }else {
            contactTextLabel.isHidden = false
            contactLabel.isHidden = false
            contactLabel.text = user.contact
        }
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
        if isGoogleAccount {
            GIDSignIn.sharedInstance.signOut()
        }
        navigationController?.popToRootViewController(animated: true)
    }
    //
    //MARK: homeBtnAction
    //
    @IBAction func homeBtnAction(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
    }
}

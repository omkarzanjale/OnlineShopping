//
//  SignInViewController.swift
//  OnlineShopping
//
//  Created by Mac on 09/11/21.
//

import UIKit
import GoogleSignIn

protocol SignInViewControllerProtocol: class {
    func updatedInfo(user: User)
}

class SignInViewController: UIViewController {
    //
    //MARK: Outlet
    //
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    weak var delegate: SignInViewControllerProtocol?
    private var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        passwordTextField.isSecureTextEntry = true
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    private func validateTextField() -> (email:String, password:String)? {
        guard let email = emailTextField.text else {return nil}
        guard let password = passwordTextField.text else {return nil}
        if email.isEmpty == false {
            if password.isEmpty == false {
                return (email,password)
            } else {
                showAlert(title: "Warning", message: "Enter password!!!")
            }
        } else {
            showAlert(title: "Waring", message: "Enter Email!!!")
        }
        return nil
    }
    
    private func checkUserInDatabase() -> Bool? {
        guard  let userData = validateTextField() else {return nil}
        if let user = DatabaseHelper().getUserWith(email: userData.email, password: userData.password) {
            self.user = user
            return true
        } else {
            return false
        }
    }
    //
    //MARK: signIn Btn Action
    //
    @IBAction func signInBtnAction(_ sender: Any) {
        guard let checkUserInDatabase = checkUserInDatabase() else {return}
        if checkUserInDatabase {
            self.delegate?.updatedInfo(user: user!)
            if let userProfileViewControllerObj = storyboard?.instantiateViewController(withIdentifier: "UserProfileViewController") as? UserProfileViewController {
                userProfileViewControllerObj.user = user
                navigationController?.pushViewController(userProfileViewControllerObj, animated: true)
            } else {
                print("Unable to find UserProfileViewController in storyboard!")
            }
            
        } else {
            showAlert(title: "Warining", message: "Invalid Email or Password!")
        }
    }
    //
    //MARK: signUpBtnAction
    //
    @IBAction func signUpBtnAction(_ sender: Any) {
        if let signUpViewControllerObj = storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as? SignUpViewController {
            navigationController?.pushViewController(signUpViewControllerObj, animated: true)
        } else {
            print("Unable to locate SignUpViewController in storyboard!")
        }
    }
    //
    //MARK: Google Login
    //
    @IBAction func googleLoginBtnAction(_ sender: Any) {
        let signInConfig = GIDConfiguration(clientID: "627835855505-2r9b5uc932ugd65hom6t4hqnlhi8ju7g.apps.googleusercontent.com")
        GIDSignIn.sharedInstance.signIn(with: signInConfig, presenting: self) { (user, error) in
            if error == nil {
                guard let user = user?.profile else {return}
                let userModel = User(name: user.name, email: user.email, contact: "", password: "")
                self.delegate?.updatedInfo(user: userModel)
                if let userProfileViewControllerObj = self.storyboard?.instantiateViewController(withIdentifier: "UserProfileViewController") as? UserProfileViewController {
                    userProfileViewControllerObj.isGoogleAccount = true
                    userProfileViewControllerObj.user = userModel
                    self.navigationController?.pushViewController(userProfileViewControllerObj, animated: true)
                } else {
                    print("Unable to find UserProfileViewController in storyboard!")
                }
            } else {
                self.showAlert(title: "Failed", message:     "Unable to Login using Google!")
            }
        }
    }
}

extension UIViewController: UITextFieldDelegate {
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

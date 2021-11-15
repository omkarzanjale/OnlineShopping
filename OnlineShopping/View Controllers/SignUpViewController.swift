//
//  SignUPViewController.swift
//  OnlineShopping
//
//  Created by Mac on 10/11/21.
//

import UIKit

class SignUpViewController: UIViewController {
    //
    //MARK: Outlets
    //
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var contactTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var reEnterTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    private func showAlert(title: String, message: String, navigate: Bool = false) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if navigate{
            alert.addAction(UIAlertAction(title: "SignIn", style: .default, handler: { (_) in
                self.navigationController?.popViewController(animated: true)
            }))
        } else {
            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        }
        present(alert, animated: true, completion: nil)
    }
    
    private func validateTextFields() -> User? {
        guard let name = nameTextField.text else {return nil}
        guard let email = emailTextField.text else {return nil}
        guard let contact = contactTextField.text else {return nil}
        guard let password = passwordTextField.text else {return nil}
        guard let reEnterPassword = reEnterTextField.text else {return nil}
        if name.isEmpty==true||email.isEmpty==true||contact.isEmpty==true||password.isEmpty==true {
            showAlert(title: "Warning", message: "Fill all fields!")
            return nil
        } else {
            if let _ = Int(contact) {
                if password == reEnterPassword {
                    let user = User(name: name, email: email, contact: contact, password: password)
                    return user
                } else {
                    showAlert(title: "Warning", message: "Password mismatch!")
                    return nil
                }
            } else {
                showAlert(title: "Warning", message: "Check contact!")
                return nil
            }
        }
    }
    //
    //MARK: signUpBtnAction
    //
    @IBAction func signUpBtnAction(_ sender: Any) {
        guard let user = validateTextFields() else {return}
        DatabaseHelper().insertIntoUser(user: user) { (title, message) in
            showAlert(title: title, message: message, navigate: true)
        } failure: { (title, message) in
            showAlert(title: title, message: message)
        }
    }
    //
    //MARK: signInBtnAction
    //
    @IBAction func signInBtnAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

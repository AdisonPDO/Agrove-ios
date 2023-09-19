//
//  SignUpVC.swift
//  plantR_ios
//
//  Created by Rabissoni on 17/01/2019.
//  Copyright © 2019 Rabissoni. All rights reserved.
//

import UIKit
import Firebase
import RGPD

class SignUpVC: UIViewController {

    @IBOutlet var firstnameTextField: UITextField!
    @IBOutlet var lastnameTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var confirmPasswordTextField: UITextField!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var userRepository: UserRepository!
    var userTransformer: UserTransformer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
              RGPD.shared.hasAllAuthorizations { result in
                   if !result {
                       DispatchQueue.main.async {
                           RGPD.shared.showRGPDModally(self)
                       }
                   }
               }
        }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    @IBAction func backTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @IBAction func createTapped(_ sender: UIButton) {
        guard let firstName = firstnameTextField.text, let lastName = lastnameTextField.text else { return }
        let validator = UserValidator(firstname: firstName, lastname: lastName, email: emailTextField.text!, password: passwordTextField.text, confirmPassword: confirmPasswordTextField.text, currentPassword: nil)
        if validator.errorMessage != nil {
            popOKAlertController(title: validator.errorMessage!)
        } else {
            activityIndicator.startAnimating()
            sender.isEnabled = false
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (authResult, error) in
                sender.isEnabled = true
                self.activityIndicator.stopAnimating()
                guard let authResult = authResult else {
                    self.popOKAlertController(title: error!.localizedFirebaseAuthDescription)
                    return
                }
                let uid = authResult.user.uid
                let userDictonary = self.userTransformer.toDictonary(UserMetadataModel(firstName: firstName, lastName: lastName))
                self.userRepository.getMetadataReference(for: uid).setValue(userDictonary, withCompletionBlock: { (authResult, error) in
                  self.navigationController?.dismiss(animated: true, completion: nil)
                })
            }
            
        }
    }
}

extension SignUpVC: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
}

//
//  ViewController.swift
//  LoginFirebase
//
//  Created by Danilo Requena on 17/01/21.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {
    
    private let titleLabel: UILabel = {
       let label = UILabel()
        label.text = "Login"
        label.textColor = .black
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 22)
        return label
    }()
    
    private let emailField: UITextField = {
       let emailField = UITextField()
        emailField.placeholder = "E-mail Addrees"
        emailField.layer.borderWidth = 1
        emailField.layer.borderColor = UIColor.black.cgColor
        emailField.layer.cornerRadius = 10
        emailField.keyboardType = .emailAddress
        emailField.autocapitalizationType = .none
        emailField.leftViewMode = .always
        emailField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        return emailField
    }()
    
    private let passField: UITextField = {
       let passField = UITextField()
        passField.placeholder = "Password"
        passField.isSecureTextEntry = true
        passField.layer.borderWidth = 1
        passField.layer.borderColor = UIColor.black.cgColor
        passField.layer.cornerRadius = 10
        passField.leftViewMode = .always
        passField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        return passField
    }()

    
    private let buttonGo: UIButton = {
       let button = UIButton()
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Continue", for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()
    
    private let signOutButton: UIButton = {
       let button = UIButton()
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Log Out", for: .normal)
        button.layer.cornerRadius = 10
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        titleLabel.frame = CGRect(x: 0,
                                  y: 100,
                                  width: view.frame.size.width,
                                  height: 80)
        
        emailField.frame = CGRect(x: 20,
                                  y: titleLabel.frame.origin.y + titleLabel.frame.size.height + 10,
                                  width: view.frame.size.width - 40,
                                  height: 50)
        
        passField.frame = CGRect(x: 20,
                                 y: emailField.frame.origin.y + emailField.frame.size.height + 10,
                                 width: view.frame.size.width - 40,
                                 height: 50)
        buttonGo.frame = CGRect(x: 20,
                                y: passField.frame.origin.y + passField.frame.size.height + 30,
                                width: view.frame.size.width - 40,
                                height: 52)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if FirebaseAuth.Auth.auth().currentUser != nil {
            emailField.resignFirstResponder()
        }
    }
    
    func setupLayout() {
        view.addSubview(titleLabel)
        view.addSubview(emailField)
        view.addSubview(passField)
        view.addSubview(buttonGo)
        
        buttonGo.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
        
        if FirebaseAuth.Auth.auth().currentUser != nil {
            titleLabel.isHidden = true
            emailField.isHidden = true
            passField.isHidden = true
            buttonGo.isHidden = true
            
            signOutButton.frame = CGRect(x: 20, y: 150, width: view.frame.size.width - 40, height: 52)
            view.addSubview(signOutButton)
            signOutButton.addTarget(self, action: #selector(logout), for: .touchUpInside)
        }
    }
    
    @objc func buttonAction()  {
        print("Foi!!!")
        guard let email = emailField.text, !email.isEmpty,
              let password = passField.text, !password.isEmpty  else {
            print("missing filed data")
            return
        }
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion:  { [weak self] result, error in
            guard let strongSelf = self else {
                return
            }
            
            guard error == nil else {
                // show account creation
                strongSelf.showCreateAccount(email: email, password: password)
                return
            }
            
            print("You have signed in")
            strongSelf.titleLabel.isHidden = true
            strongSelf.emailField.isHidden = true
            strongSelf.passField.isHidden = true
            strongSelf.buttonGo.isHidden = true
            
            strongSelf.emailField.resignFirstResponder()
            strongSelf.passField.resignFirstResponder()
        })
    }
    
    @objc func logout() {
        do {
            try FirebaseAuth.Auth.auth().signOut()
            titleLabel.isHidden = false
            emailField.isHidden = false
            passField.isHidden = false
            buttonGo.isHidden = false
            
            signOutButton.removeFromSuperview()
        } catch {
            print("An error occured")
        }
    }
    
    func showCreateAccount(email: String, password: String) {
        let alert = UIAlertController(title: "Create Account",
                                      message: "Would you like to create an account?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Continue",
                                      style: .default,
                                      handler: { _ in
                                        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { [weak self] result, error in
                                            
                                            guard let strongSelf = self else {
                                                return
                                            }
                                            
                                            guard error == nil else {
                                                // show account creation
                                                print("Account creation failed")
                                                return
                                            }
                                            
                                            print("You have signed in")
                                            strongSelf.titleLabel.isHidden = true
                                            strongSelf.emailField.isHidden = true
                                            strongSelf.passField.isHidden = true
                                            strongSelf.buttonGo.isHidden = true
                                            
                                            strongSelf.emailField.resignFirstResponder()
                                            strongSelf.passField.resignFirstResponder()
                                        })
                                    }))
        
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: .cancel,
                                      handler: { _ in
                                        
                                      }))
        
        present(alert, animated: true, completion: nil)
    }
}


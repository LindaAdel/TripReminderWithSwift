//
//  SignUpViewController.swift
//  TripReminder
//
//  Created by Linda adel on 12/20/21.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {
    
    var ref : DatabaseReference! = Database.database().reference()
    //MARK: IBOutlets
    
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.alpha = 0
    }
    //MARK: IBActions
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        
        creatUserAccount()
    }
    
    
    @IBAction func navigateToLoginScreen(_ sender: UIButton) {
        
        if let logInVC = self.storyboard?.instantiateViewController(withIdentifier: "login") as? LogInViewController{
            logInVC.modalPresentationStyle = .fullScreen
            self.present(logInVC, animated: true, completion: nil)}
    }
    
    //MARK: Methods
    
    //8 character contain num,alpha,specialcharacter
    func isPasswordValid(_ password : String) -> Bool{
        let passwordCheck = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")
        return passwordCheck.evaluate(with: password)
    }
    // mail syntacs validation
    func isValidEmail(_ email:String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.com"
       // let emailRegex = "[A-Z0-9a-z._%+-]+@(yahoo|hotmail|gmail)+\\.com"
        let emailCheck = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailCheck.evaluate(with: email)
        
    }
    // creadential check
    //validate fields if not correct print error message and return false if correct return true
    func fieldsCreadentialCheck() -> Bool{
        //check if all fields are filled
        if emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            emailTextField.showTextFieldError(placeholderValue: "required")
            passwordTextField.showTextFieldError(placeholderValue: "required")
            print( "all fields are empty")
            return false
        }
        // check password for validation checks
        let userPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if isPasswordValid(userPassword) == false {
            errorLabel.showError("invalid password format")
            print("invalid password format")
            return false
        }
        // check email for validation checks
        let userMail = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if isValidEmail(userMail) == false {
            errorLabel.showError("invalid mail format")
            print("invalid mail format")
            return false
        }
        return true
    }
    //MARK:  creat user
    func creatUserAccount(){
        if fieldsCreadentialCheck() {
            let userEmail = emailTextField.text!
            let userPassword = passwordTextField.text!
            
            Firebase.Auth.auth().createUser(withEmail: userEmail , password: userPassword) { (AuthDataResult, error) in
                if let error = error {
                    print(error.localizedDescription)
                }else
                {
                    // user created
                    if let userId = Auth.auth().currentUser?.uid
                    { print(userId)
                    }
                    // to open sign up only in the first time when the user using the app
                    UserDefaults.standard.setValue(false, forKey: "signup")
                    self.natigateToHome()
                    
                }
            }
        }
    }
    func natigateToHome(){
        
        if let HomeVC = self.storyboard?.instantiateViewController(withIdentifier: "homeCalender") as? CalenderHomeViewController{
            HomeVC.modalPresentationStyle = .fullScreen
            self.present(HomeVC, animated: true, completion: nil)}
        
    }
}


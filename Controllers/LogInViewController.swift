//
//  LogInViewController.swift
//  TripReminder
//
//  Created by Linda adel on 12/20/21.
//

import UIKit
import Firebase
import GoogleSignIn

class LogInViewController: UIViewController {
    
    var firebaseManger : FirebaseManger?
    var authPassword : String?
    
    //MARK: IBOutlet
    
    
    @IBOutlet weak var emailTextField: UITextField!
    
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.alpha = 0
        firebaseManger = FirebaseManger.shared
        //getPasswordFromFirebase()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self
        
        // Do any additional setup after loading the view.
    }
    //MARK: IBAction
    
    @IBAction func loginToApp(_ sender: UIButton) {
        self.fireBaseLogIn()
    }
    
    @IBAction func navigateToSignupScreen(_ sender: UIButton) {
        if let signUpVC = self.storyboard?.instantiateViewController(withIdentifier: "signup") as? SignUpViewController{
            signUpVC.modalPresentationStyle = .fullScreen
            self.present(signUpVC, animated: true, completion: nil)}
    }
    
    @IBAction func loginWithGoogle(_ sender: UIButton) {
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    
}
//MARK:handle google signin process
extension LogInViewController : GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            print(error.localizedDescription)
        }else{
            if let authentication = user?.authentication
            {
                let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken ,accessToken: authentication.accessToken)
                
                Auth.auth().signIn(with: credential) { (authResult, error) in
                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        self.natigateToHome()
                    }
                }
                
                
            }
        }
    }
    //MARK: Methods
    
    // mail syntacs validation
    func isValidEmail(_ email:String) -> Bool {
        
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.com"
       // let emailRegex = "[A-Z0-9a-z._%+-]+@(yahoo|hotmail|gmail)+\\.com"
        let emailCheck = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailCheck.evaluate(with: email)
        
    }
    //MARK: creadential check
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
    
        //MARK: check email for validation checks
        let userMail = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if isValidEmail(userMail) == false {
            errorLabel.showError("invalid mail format")
            print("invalid mail format")
            return false
        }
        return true
    }
    //MARK: user log in
    func fireBaseLogIn(){
        if fieldsCreadentialCheck() {
            let userEmail = emailTextField.text!
            let userPassword = passwordTextField.text!
            
            Auth.auth().signIn(withEmail: userEmail , password: userPassword) { (AuthDataResult, error ) in
                if let error = error {
                    print(error.localizedDescription)
                    self.errorLabel.showError("incorrect password")
                }else
                {
                    // user created
                    if let userId = Auth.auth().currentUser?.uid
                    
                    { print(userId)
                        self.getUserSyncValue()
                    }
                    
                }
                
            }
        }
        
        
    }
    func natigateToHome(){
        if let HomeVC = self.storyboard?.instantiateViewController(withIdentifier: "homeCalender") as? CalenderHomeViewController{
            HomeVC.modalPresentationStyle = .fullScreen
            self.present(HomeVC, animated: true, completion: nil)}
        
    }
    
    //MARK: get user sync value
    func getUserSyncValue(){
        firebaseManger?.getSyncIndicator(completion: { syncValue in
            print("syncValue \(String(describing: syncValue))")
            if let sync = syncValue {
                CalenderHomeViewController.switchBool = sync
                self.natigateToHome()
                print(" syncToFireBase \( String(describing:  CalenderHomeViewController.switchBool ))")
                
            }
        })
        
    }
   
}

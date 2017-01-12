//
//  Registration.swift
//  Heyphil
//
//  Created by Philcare on 12/12/2016.
//  Copyright © 2016 Philcare. All rights reserved.
//

import UIKit
class Registration: UIViewController, FBSDKLoginButtonDelegate, UITextFieldDelegate {
    
    
    @IBOutlet weak var header: UIImageView!
    @IBOutlet weak var loginFacebook: UIButton!
    @IBOutlet weak var txtFirstname: UITextField!
    @IBOutlet weak var txtLastname: UITextField!
    @IBOutlet weak var txtMiddlename: UITextField!
    @IBOutlet weak var txtBldgno: UITextField!
    @IBOutlet weak var txtStreet: UITextField!
    @IBOutlet weak var txtBrgy: UITextField!
    @IBOutlet weak var txtProvince: UITextField!
    @IBOutlet weak var txtCity: UITextField!
    @IBOutlet weak var txtHomenumber: UITextField!
    @IBOutlet weak var txtMobilenumber: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var txtConfirmpass: UITextField!
    @IBOutlet weak var btnCancel: UIButton!
    @IBOutlet weak var btnSubmit: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        loginFacebook.layer.borderWidth=2
        loginFacebook.layer.cornerRadius=5
        loginFacebook.layer.borderColor = UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1.0).cgColor;
        txtFirstname.layer.borderWidth=2
        txtFirstname.layer.cornerRadius=5
        txtFirstname.layer.borderColor = UIColor(red: 0.00, green: 0.40, blue: 0.00, alpha: 1.0).cgColor;
        txtFirstname.delegate = self
        txtLastname.layer.borderWidth=2
        txtLastname.layer.cornerRadius=5
        txtLastname.layer.borderColor = UIColor(red: 0.00, green: 0.40, blue: 0.00, alpha: 1.0).cgColor;
        txtLastname.delegate = self
        txtMiddlename.layer.borderWidth=2
        txtMiddlename.layer.cornerRadius=5
        txtMiddlename.layer.borderColor = UIColor(red: 0.00, green: 0.40, blue: 0.00, alpha: 1.0).cgColor;
        txtMiddlename.delegate = self
        txtBldgno.layer.borderWidth=2
        txtBldgno.layer.cornerRadius=5
        txtBldgno.layer.borderColor = UIColor(red: 0.00, green: 0.40, blue: 0.00, alpha: 1.0).cgColor;
        txtBldgno.delegate = self
        txtStreet.layer.borderWidth=2
        txtStreet.layer.cornerRadius=5
        txtStreet.layer.borderColor = UIColor(red: 0.00, green: 0.40, blue: 0.00, alpha: 1.0).cgColor;
        txtStreet.delegate = self
        txtBrgy.layer.borderWidth=2
        txtBrgy.layer.cornerRadius=5
        txtBrgy.layer.borderColor = UIColor(red: 0.00, green: 0.40, blue: 0.00, alpha: 1.0).cgColor;
        txtBrgy.delegate = self
        txtProvince.layer.borderWidth=2
        txtProvince.layer.cornerRadius=5
        txtProvince.layer.borderColor = UIColor(red: 0.00, green: 0.40, blue: 0.00, alpha: 1.0).cgColor;
        txtProvince.delegate = self
        txtCity.layer.borderWidth=2
        txtCity.layer.cornerRadius=5
        txtCity.layer.borderColor = UIColor(red: 0.00, green: 0.40, blue: 0.00, alpha: 1.0).cgColor;
        txtCity.delegate = self
        txtHomenumber.layer.borderWidth=2
        txtHomenumber.layer.cornerRadius=5
        txtHomenumber.layer.borderColor = UIColor(red: 0.00, green: 0.40, blue: 0.00, alpha: 1.0).cgColor;
        txtHomenumber.delegate = self
        txtMobilenumber.layer.borderWidth=2
        txtMobilenumber.layer.cornerRadius=5
        txtMobilenumber.layer.borderColor = UIColor(red: 0.00, green: 0.40, blue: 0.00, alpha: 1.0).cgColor;
        txtMobilenumber.delegate = self
        txtEmail.layer.borderWidth=2
        txtEmail.layer.cornerRadius=5
        txtEmail.layer.borderColor = UIColor(red: 0.00, green: 0.40, blue: 0.00, alpha: 1.0).cgColor;
        txtEmail.delegate = self
        txtPassword.layer.borderWidth=2
        txtPassword.layer.cornerRadius=5
        txtPassword.layer.borderColor = UIColor(red: 0.00, green: 0.40, blue: 0.00, alpha: 1.0).cgColor;
        txtPassword.delegate = self
        txtConfirmpass.layer.borderWidth=2
        txtConfirmpass.layer.cornerRadius=5
        txtConfirmpass.layer.borderColor = UIColor(red: 0.00, green: 0.40, blue: 0.00, alpha: 1.0).cgColor;
        txtConfirmpass.delegate = self
        btnCancel.layer.borderWidth=2
        btnCancel.layer.cornerRadius=5
        btnCancel.layer.borderColor = UIColor(red: 0.00, green: 0.40, blue: 0.00, alpha: 1.0).cgColor;
        btnSubmit.layer.borderWidth=2
        btnSubmit.layer.cornerRadius=5
        btnSubmit.layer.borderColor = UIColor(red: 0.00, green: 0.40, blue: 0.00, alpha: 1.0).cgColor;
        header.backgroundColor = UIColor(colorLiteralRed: 0.00, green: 0.40, blue: 0.00, alpha: 1)
        // Do any additional setup after loading the view.
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func fbLogin(_ sender: Any) {
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) -> Void in
            if (error == nil){
                let fbloginresult : FBSDKLoginManagerLoginResult = result!
                if(fbloginresult.grantedPermissions.contains("email"))
                {
                    self.getFBUserData()
                }
            }
        }
    }
    
    func getFBUserData(){
    if((FBSDKAccessToken.current()) != nil){
        FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(large), email"]).start(completionHandler: { (connection, result, error) -> Void in
            if (error == nil){
                //everything works print the user data
                print(result)
            }
        })
    }
}

@IBAction func btn_Submit(_ sender: Any) {
        if(txtFirstname.text?.isEmpty)!
        {
         txtFirstname.layer.borderColor = UIColor.red.cgColor
        }
        else
        {txtFirstname.layer.borderColor = UIColor(red: 0.00, green: 0.40, blue: 0.00, alpha: 1.0).cgColor;
        }
        if(txtLastname.text?.isEmpty)!
        {
            txtLastname.layer.borderColor = UIColor.red.cgColor
        }
        else
        {
            txtLastname.layer.borderColor = UIColor(red: 0.00, green: 0.40, blue: 0.00, alpha: 1.0).cgColor;
        }
        if(txtBrgy.text?.isEmpty)!
        {
            txtBrgy.layer.borderColor = UIColor.red.cgColor
        }
        else
        {
            txtBrgy.layer.borderColor = UIColor(red: 0.00, green: 0.40, blue: 0.00, alpha: 1.0).cgColor;
        }
        if(txtProvince.text?.isEmpty)!
        {
            txtProvince.layer.borderColor = UIColor.red.cgColor
        }
        else
        {
            txtProvince.layer.borderColor = UIColor(red: 0.00, green: 0.40, blue: 0.00, alpha: 1.0).cgColor;
        }
        if(txtCity.text?.isEmpty)!
        {
            txtCity.layer.borderColor = UIColor.red.cgColor
        }
        else
        {
            txtCity.layer.borderColor = UIColor(red: 0.00, green: 0.40, blue: 0.00, alpha: 1.0).cgColor;
        }
        if(txtHomenumber.text?.isEmpty)!
        {
            txtHomenumber.layer.borderColor = UIColor.red.cgColor
        }
        else
        {
            txtHomenumber.layer.borderColor = UIColor(red: 0.00, green: 0.40, blue: 0.00, alpha: 1.0).cgColor;
        }
        if(txtMobilenumber.text?.isEmpty)!
        {
            txtMobilenumber.layer.borderColor = UIColor.red.cgColor
        }
        else
        {
            txtMobilenumber.layer.borderColor = UIColor(red: 0.00, green: 0.40, blue: 0.00, alpha: 1.0).cgColor;
        }
        if(txtEmail.text?.isEmpty)!
        {
            txtEmail.layer.borderColor = UIColor.red.cgColor
        }
        else
        {
            txtEmail.layer.borderColor = UIColor(red: 0.00, green: 0.40, blue: 0.00, alpha: 1.0).cgColor;
        }
        if(txtPassword.text?.isEmpty)!
        {
            txtPassword.layer.borderColor = UIColor.red.cgColor
        }
        else
        {
            txtPassword.layer.borderColor = UIColor(red: 0.00, green: 0.40, blue: 0.00, alpha: 1.0).cgColor;
        }
        if(txtConfirmpass.text?.isEmpty)!
        {
            txtConfirmpass.layer.borderColor = UIColor.red.cgColor
        }
        else
        {
            txtConfirmpass.layer.borderColor = UIColor(red: 0.00, green: 0.40, blue: 0.00, alpha: 1.0).cgColor;
        }
    }
    
    @IBAction func btn_Cancel(_ sender: Any) {
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
    }
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!){
    }
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool
    {
        return true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

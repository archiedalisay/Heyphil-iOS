//
//  PreRegister.swift
//  Heyphil
//
//  Created by Philcare on 12/12/2016.
//  Copyright © 2016 Philcare. All rights reserved.
//

import UIKit

class PreRegister: UIViewController {

    @IBOutlet weak var txtCert: UITextField!
    @IBOutlet weak var txtBday: UITextField!
    @IBOutlet weak var btnVerify: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        txtCert.layer.borderWidth=2
        txtCert.layer.cornerRadius=5
        txtCert.layer.borderColor=UIColor(red: 0.00, green: 0.40, blue: 0.00, alpha: 1.0).cgColor;
        txtBday.layer.borderWidth=2
        txtBday.layer.cornerRadius=5
        txtBday.layer.borderColor=UIColor(red: 0.00, green: 0.40, blue: 0.00, alpha: 1.0).cgColor;
        btnVerify.layer.cornerRadius=5
        
        print("Welcome")
        // Do any additional setup after loading the view.
    }
    
    @IBAction func datePicker(_ sender: UITextField) {
        let datePickerView: UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(PreRegister.datePickerValueChanged(sender:)), for: UIControlEvents.valueChanged)
        
    }
    
    @IBAction func btnVerifyAction(_ sender: Any) {
       if (!txtCert.text!.isEmpty || !txtBday.text!.isEmpty)
       {
        let urlString = "https://apps.philcare.com.ph/PhilcareWatsonTest/Search.svc/PhilcareWatsonMemberVerification/?certNo="+txtCert.text!+"&birthDate="+txtBday.text!
        
        let url = URL(string: urlString)
        URLSession.shared.dataTask(with:url!) { (data, response, error) in
            if error != nil
            {
                print(error as Any)
            }
            else {
                do {
                    
                    let parsedData = try JSONSerialization.jsonObject(with: data!, options: []) as! [String:Any]
                    print(parsedData)
                    let currentConditions = parsedData["PhilcareWatsonMemberVerificationResult"] as? [[String:Any]]
                    var  successFlag:Int = currentConditions?[0]["SuccessFlag"] as Any as! Int
                    var sf = String(successFlag)
                    var  mismatchFlag:Int = currentConditions?[0]["MismatchFlag"] as Any as! Int
                    var mf = String(mismatchFlag)
                    var  duplicatedFlag:Int = currentConditions?[0]["DuplicateFlag"] as Any as! Int
                    var df = String(duplicatedFlag)
                    var  deactivatedFlag:Int = currentConditions?[0]["DeactivatedFlag"] as Any as! Int
                    var  terminatedFlag:Int = currentConditions?[0]["TerminatedFlag"] as Any as! Int
                    
                    if (  sf == "1")
                    {
                        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        let vc: UIViewController = storyBoard.instantiateViewController(withIdentifier: "registration")
                        
                        OperationQueue.main.addOperation {
                            self.present(vc, animated: true, completion: nil)
                        }
                    }
                    else if ( mf == "1")
                    {
                        let alert = UIAlertController(title: "Login Failed!", message: "Your Certificate Number and Birthday doesn't match!", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
                        OperationQueue.main.addOperation {
                            self.present(alert, animated: true, completion: nil)
                        }
                        
                    }
                    else if ( df == "1")
                    {
                        let alert = UIAlertController(title: "Login Failed!", message: "You have already an existing account.", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
                        OperationQueue.main.addOperation {
                            self.present(alert, animated: true, completion: nil)
                        }                    }
                    else if ( String(deactivatedFlag) == "1")
                    {
                        let alert = UIAlertController(title: "Login Failed!", message: "Your account is deactivated!", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
                        OperationQueue.main.addOperation {
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                    else if ( String(terminatedFlag) == "1")
                    {
                        let alert = UIAlertController(title: "Login Failed!", message: "You can't able to resgister because your account has been terminated!", preferredStyle: UIAlertControllerStyle.alert)
                        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
                        OperationQueue.main.addOperation {
                            self.present(alert, animated: true, completion: nil)
                        }
                    }
                    //let currentTemperatureF = currentConditions["temperature"] as! Double
                    //print(currentTemperatureF)
                }
                    catch let error as NSError {
                    print(error)
                }
            }
            
            }.resume()
        }
        else{
            
        }
    }
    func datePickerValueChanged(sender:UIDatePicker) {
        
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "YYYY-MM-dd"
        //dateFormatter.dateStyle = DateFormatter.Style.medium
        
        //dateFormatter.timeStyle = DateFormatter.Style.none
        
        txtBday.text = dateFormatter.string(from: sender.date)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

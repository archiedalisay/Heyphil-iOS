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

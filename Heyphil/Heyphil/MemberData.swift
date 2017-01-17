//
//  MemberData.swift
//  Heyphil
//
//  Created by Philcare on 28/12/2016.
//  Copyright © 2016 Philcare. All rights reserved.
//

import UIKit

class MemberData: UIViewController {

    @IBOutlet var MainView: UIView!
    @IBOutlet weak var SubView: UIView!
    @IBOutlet weak var txtCert: UILabel!
    
    @IBOutlet weak var txtLname: UILabel!
    @IBOutlet weak var txtFname: UILabel!
    @IBOutlet weak var txtMname: UILabel!
    @IBOutlet weak var txtGender: UILabel!
    @IBOutlet weak var txtCivil: UILabel!
    @IBOutlet weak var txtBday: UILabel!
    @IBOutlet weak var txtAddress: UILabel!
    @IBOutlet weak var txtMobile: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isOpaque = true
        self.view.backgroundColor = UIColor.clear
        SubView.layer.borderWidth = 2
        SubView.layer.borderColor = UIColor.gray.cgColor
        txtCert.text = MemberInfo.CertNo
        txtLname.text = MemberInfo.Lastname
        txtFname.text = MemberInfo.Firstname
        txtMname.text = MemberInfo.Middlename
        txtGender.text = MemberInfo.Sex
        txtBday.text = MemberInfo.Birthdate
        txtAddress.text = MemberInfo.Address
        txtMobile.text = MemberInfo.ContactNumber
        txtCert.lineBreakMode = .byWordWrapping
        txtAddress.lineBreakMode = .byWordWrapping
        txtCert.sizeToFit()
        txtLname.sizeToFit()
        txtFname.sizeToFit()
        txtMname.sizeToFit()
        txtGender.sizeToFit()
        txtCivil.sizeToFit()
        txtBday.sizeToFit()
        txtAddress.sizeToFit()
        txtMobile.sizeToFit()
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(MemberData.close))
        SubView.addGestureRecognizer(tap)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func close()
    {
        self.dismiss(animated: true, completion: nil)
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

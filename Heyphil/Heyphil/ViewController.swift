//
//  ViewController.swift
//  Heyphil
//
//  Created by Philcare on 08/12/2016.
//  Copyright © 2016 Philcare. All rights reserved.
//

import UIKit
import TextToSpeechV1
import AVFoundation
class ViewController: UIViewController,XMLParserDelegate, FBSDKLoginButtonDelegate{
    let textToSpeech = TextToSpeech(username: "731f1d70-99cf-48fa-8228-4a6c8b422890", password: "T3Eulf1y8EXQ")
    let loginButon: FBSDKLoginButton = {
        let button = FBSDKLoginButton()
        button.readPermissions = ["email"]
        return button
    }()
    var audioPlayer = AVAudioPlayer()    //XML Parser
    var parser = XMLParser()
    var post = NSMutableArray()
    var elements = NSMutableDictionary()
    var element = NSString()
    var title1 = NSMutableString()
    var date = NSMutableString()
    var str_username=""
    var str_password=""
    var message = String()
    var loginLink = String()
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var lblSignup: UILabel!
    
    @IBAction func btnLogin(_ sender: AnyObject) {
        str_username=txtUsername.text!
        str_password=txtPassword.text!
        loginLink = "https://apps.philcare.com.ph/PhilcareWatsonTest/Login.svc/Loginjsn/?Username="+str_username+"&pwd="+str_password+"&UserID=&Email=&FbFrom=0"
        login()
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
        view.addSubview(loginButon)
        loginButon.center = view.center
        loginButon.delegate = self
        if let token = FBSDKAccessToken.current()
        {
            fetchprofile()
        }
        let text = "Hello I'm Phil, how can I help you today!"
        let failure = { (error: Error) in print(error) }
        textToSpeech.synthesize(text, voice: SynthesisVoice.us_Michael.rawValue, failure: failure) { data in
            self.audioPlayer = try! AVAudioPlayer(data: data)
            self.audioPlayer.play()
        }
        let tap=UITapGestureRecognizer(target:self,action: #selector(ViewController.Signup))
            lblSignup.isUserInteractionEnabled=true
            lblSignup.addGestureRecognizer(tap)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        fetchprofile()
    }
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!){
    }
    func loginButtonWillLogin(_ loginButton: FBSDKLoginButton!) -> Bool
    {
        return true
    }
    func fetchprofile()
    {
        let parameters = ["fields": "email, first_name, last_name, picture.type(large)"]
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: parameters)
        graphRequest.start { (connection, result, error) in
            if let profile = result as?[String: AnyObject]
            {
                print(profile)
                let email = profile["email"] as? String
                let id = profile["id"] as? String
                print(email as Any)
                print(id as Any)
                if let picture = profile["picture"] as? NSDictionary, let data = picture["data"] as? NSDictionary, let url = data["url"] as? String{
                    print(url)
                    
                }
                self.loginLink = link.DEFAULTLINK+"Login.svc/Loginjsn/?Username=&pwd=&UserID="+id!+"&Email="+email!+"&FbFrom=1"
                self.login()
            }
        }
        
    }
    func conversation()
    {
        let storyBoard: UIStoryboard = UIStoryboard (name: "Main", bundle: nil)
        let conversationView=storyBoard.instantiateViewController(withIdentifier: "conversation")
        self.present(conversationView, animated: true, completion: nil)
    }
    func login()
    {
        let url = URL(string: loginLink)
        let task=URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil
            {
                print("ERROR")
            }
            else
            {
                if let content=data
                {
                    do{
                        let json = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        print (json)
                        if let login = json["LoginMemberJsnResult"] as? [String: AnyObject]
                        {
                            MemberInfo.Birthdate=(login["BirthDate"] as! String);
                            MemberInfo.CertNo=(login["CertNo"] as! String);
                            MemberInfo.Firstname=(login["FirstName"] as! String);
                            MemberInfo.Lastname=(login["LastName"] as! String);
                            MemberInfo.Email=(login["Email"] as! String);
                            MemberInfo.Username=(login["UserNameOut"] as! String);
                            if ((login["SuccessFlag"] as! String) == "True")
                            {
                                self.memberInfo()
                                let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                let vc: UIViewController = storyBoard.instantiateViewController(withIdentifier: "conversation")
                                
                                OperationQueue.main.addOperation {
                                    self.present(vc, animated: true, completion: nil)
                                }
                                
                            }
                            else
                            {
                                let alert = UIAlertController(title: "Login Failed!", message: (login["MessageReturn"] as! String), preferredStyle: UIAlertControllerStyle.alert)
                                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.default, handler: nil))
                                OperationQueue.main.addOperation {
                                self.present(alert, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                    catch
                    {
                        
                    }
                }
            }

        }) 
        task.resume()
    }
    func memberInfo()
    {
        let url = URL(string: link.DEFAULTLINK+"Members.svc/MembersInfojsn/?CertNo="+MemberInfo.CertNo)
        let task=URLSession.shared.dataTask(with: url!, completionHandler: { (data, response, error) in
            if error != nil
            {
                print("ERROR")
            }
            else
            {
                if let content=data
                {
                    do{
                        let json = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        print (json)
                        if let info = json["MembersInfoJsnResult"] as? [String: AnyObject]
                        {
                            MemberInfo.APE = (info["APE"] as! String)
                            MemberInfo.Address = (info["Address"] as! String)
                            MemberInfo.AgreementName = (info["AgreementName"] as! String)
                            MemberInfo.AgreementNo = (info["AgreementNo"] as! String)
                            MemberInfo.Brgy = (info["Barangay"] as! String)
                            MemberInfo.BenefitLimit = (info["BenefitLimit"] as! String)
                            MemberInfo.Birthdate = (info["BirthDate"] as! String)
                            MemberInfo.CertNo = (info["CertNo"] as! String)
                            MemberInfo.City = (info["City"] as! String)
                            MemberInfo.CivilStatus = (info["CivilStat"] as! String)
                            MemberInfo.ContactNumber = (info["ContactNumber"] as! String)
                            MemberInfo.DateRegistered = (info["DateRegistered"] as! String)
                            MemberInfo.DateVerified = (info["DateVerified"] as! String)
                            MemberInfo.Dental = (info["Dental"] as! String)
                            MemberInfo.EffectiveDate = (info["EffectiveDate"] as! String)
                            MemberInfo.Email = (info["Email"] as! String)
                            MemberInfo.ExpiryDate = (info["ExpiryDate"] as! String)
                            MemberInfo.Firstname = (info["FirstName"] as! String)
                            MemberInfo.HomeNumber = (info["HomeNo"] as! String)
                            MemberInfo.Hospital = (info["Hospitals"] as! String)
                            MemberInfo.HouseNo = (info["HouseNo"] as! String)
                            MemberInfo.Lastname = (info["LastName"] as! String)
                            MemberInfo.MemberType = (info["MemberType"] as! String)
                            MemberInfo.Middlename = (info["MiddleName"] as! String)
                            MemberInfo.PackageDesc = (info["PackageDescription"] as! String)
                            MemberInfo.Philhealth = (info["PhilHealth"] as! String)
                            MemberInfo.PlanType = (info["PlanType"] as! String)
                            MemberInfo.PolicyNo = (info["PolicyNo"] as! String)
                            MemberInfo.PreEx = (info["PreEx"] as! String)
                            MemberInfo.PrepaidCard = (info["PrepaidCard"] as! String)
                            MemberInfo.Province = (info["Province"] as! String)
                            MemberInfo.Riders = (info["Riders"] as! String)
                            MemberInfo.RoomDesc = (info["RoomDescription"] as! String)
                            MemberInfo.RoomRate = (info["RoomRate"] as! String)
                            MemberInfo.Sex = (info["Sex"] as! String)
                            MemberInfo.Street = (info["Street"] as! String)
                            print(MemberInfo.APE)
                        }
                    }
                    catch
                    {
                        
                    }
                }
            }
            
        })
        task.resume()
    }
    func Signup(_ sender:UITapGestureRecognizer)
    {
        let storyBoard: UIStoryboard = UIStoryboard (name: "Main", bundle: nil)
        let preregisterView=storyBoard.instantiateViewController(withIdentifier: "conversation")
        self.present(preregisterView, animated: true, completion: nil)
    }
    func beginParsing()
    {
        post = []
        parser = XMLParser(contentsOf: (URL(string:""))! as URL)!
        parser.delegate = self
        parser.parse()
    }
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        element = elementName as NSString
        if (elementName).isEqual("item")
        {
            elements = NSMutableDictionary()
            elements = [:]
            title1 = NSMutableString()
            title1 = ""
            date = NSMutableString()
            date = ""
        }
    }
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        if element.isEqual("title")
        {
            title1.append(string)
        }
        else if element.isEqual("pubDate")
        {
            date.append(string)
        }
    }
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        if (elementName as NSString).isEqual("item")
        {
            if !title1.isEqual(nil)
            {
                elements.setObject(title1, forKey: "title" as NSCopying)
                
            }
            if !date.isEqual(nil)
            {
                elements.setObject(date, forKey: "date" as NSCopying)
            }
            post.add(elements)
            print(post)
        }
        
    }
}


//
//  ViewController.swift
//  Heyphil
//
//  Created by Philcare on 08/12/2016.
//  Copyright © 2016 Philcare. All rights reserved.
//

import UIKit
class ViewController: UIViewController,XMLParserDelegate{
    //XML Parser
    var parser = XMLParser()
    var post = NSMutableArray()
    var elements = NSMutableDictionary()
    var element = NSString()
    var title1 = NSMutableString()
    var date = NSMutableString()
    var username=""
    var password=""
    var message = String()
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var lblSignup: UILabel!
    
    @IBAction func btnLogin(_ sender: AnyObject) {
        username=txtUsername.text!
        password=txtPassword.text!
        login()
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
       
        
        let tap=UITapGestureRecognizer(target:self,action: #selector(ViewController.Signup))
            lblSignup.isUserInteractionEnabled=true
            lblSignup.addGestureRecognizer(tap)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func conversation()
    {
        let storyBoard: UIStoryboard = UIStoryboard (name: "Main", bundle: nil)
        let conversationView=storyBoard.instantiateViewController(withIdentifier: "conversation")
        self.present(conversationView, animated: true, completion: nil)
    }
    func login()
    {
        let url=URL(string: "https://apps.philcare.com.ph/PhilcareWatsonTest/Login.svc/Loginjsn/?Username="+username+"&pwd="+password+"&UserID=&Email=&FbFrom=0")
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
                        //print (json)
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
    func Signup(_ sender:UITapGestureRecognizer)
    {
        let storyBoard: UIStoryboard = UIStoryboard (name: "Main", bundle: nil)
        let preregisterView=storyBoard.instantiateViewController(withIdentifier: "preregister")
        self.present(preregisterView, animated: true, completion: nil)
    }
    func beginParsing()
    {
        post = []
        parser = XMLParser(contentsOf: (URL(string:"http://images.apple.com/main/rss/hotnews.rss"))! as URL)!
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


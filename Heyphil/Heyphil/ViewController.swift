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
    
    @IBOutlet weak var txtUsername: UITextField!
    @IBOutlet weak var txtPassword: UITextField!
    @IBOutlet weak var lblSignup: UILabel!
    @IBAction func btnLogin(_ sender: Any) {
        username=txtUsername.text!
        password=txtPassword.text!
        
        if(username=="archie" && password=="archie")
        {
         print("Success")
            let storyBoard: UIStoryboard = UIStoryboard (name: "Main", bundle: nil)
            let conversationView=storyBoard.instantiateViewController(withIdentifier: "conversation") as! Conversation
            self.present(conversationView, animated: true, completion: nil)
            MemberInfo.Firstname = ("Archie")
            print (MemberInfo.Firstname)
        }
        else
        {
         print("Failed")
        }
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
       
        /**beginParsing()
        let tap=UITapGestureRecognizer(target:self,action: #selector(ViewController.Signup))
            lblSignup.isUserInteractionEnabled=true
            lblSignup.addGestureRecognizer(tap)
        let url=URL(string: "https://apps.philcare.com.ph/PhilcareWatsonTest/Search.svc/SearchDoctors/?CertNo=5443460&Province=&Area=&DoctorName=&Specialization=")
        let task=URLSession.shared.dataTask(with: url!) { (data, response, error) in
        if error != nil
        {
          print("ERROR")
        }
        else
        {
          if let content=data
          {
            do{
                let json = try JSONSerialization.jsonObject(with: content, options: JSONSerialization.ReadingOptions.mutableContainers)as AnyObject
                print(json)
              }
            catch
            {
                
            }
          }
        }
        }
        task.resume()**/
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func Signup(sender:UITapGestureRecognizer)
    {
        let storyBoard: UIStoryboard = UIStoryboard (name: "Main", bundle: nil)
        let preregisterView=storyBoard.instantiateViewController(withIdentifier: "preregister") as! PreRegister
        self.present(preregisterView, animated: true, completion: nil)
    }
    func beginParsing()
    {
        post = []
        parser = XMLParser(contentsOf: (NSURL(string:"http://images.apple.com/main/rss/hotnews.rss"))! as URL)!
        parser.delegate = self
        parser.parse()
    }
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
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
        if element.isEqual(to: "title")
        {
            title1.append(string)
        }
        else if element.isEqual(to: "pubDate")
        {
            date.append(string)
        }
    }
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?)
    {
        if (elementName as NSString).isEqual(to: "item")
        {
            if !title1.isEqual(nil)
            {
                elements.setObject(title1, forKey: "title" as NSCopying)
                
            }
            if !date.isEqual(nil)
            {
                elements.setObject(date, forKey: "date" as NSCopying)
            }
            post.addObjects(from: [elements])
            print(post)
        }
        
    }
}


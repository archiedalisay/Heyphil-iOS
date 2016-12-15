//
//  Conversation.swift
//  Heyphil
//
//  Created by Philcare on 12/12/2016.
//  Copyright © 2016 Philcare. All rights reserved.
//

import UIKit

class Conversation: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var txtMessage: UITextField!
    @IBOutlet weak var tableView: UITableView!
    var names: [String] = []
    var contacts: [String] = []
    override func viewDidLoad()
    {
        super.viewDidLoad()
        txtMessage.layer.borderWidth=2
        txtMessage.layer.cornerRadius=5
        txtMessage.layer.borderColor=UIColor(red: 0.00, green: 0.40, blue: 0.00, alpha: 1.0).cgColor;
        let url=URL(string:"http://api.androidhive.info/contacts/")
        do {
            let allContactsData = try Data(contentsOf: url!)
            let allContacts = try JSONSerialization.jsonObject(with: allContactsData, options: JSONSerialization.ReadingOptions.allowFragments)
                as! [String : AnyObject]
            if let arrJSON = allContacts["contacts"] {
                for index in 0...arrJSON.count-1 {
                    let aObject = arrJSON[index] as! [String : AnyObject]
                    names.append(aObject["name"] as! String)
                    contacts.append(aObject["email"] as! String)
                }
            }
            print(names)
            print(contacts)
        }
        catch
        {
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return self.names.count;
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        print("You selected name: "+names[indexPath.row])
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if !(cell != nil) {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        cell?.textLabel?.text=self.names[indexPath.row]
        cell?.detailTextLabel?.text = self.contacts[indexPath.row]
        return cell!
    }
}

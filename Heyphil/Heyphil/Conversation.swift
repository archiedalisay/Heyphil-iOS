//
//  Conversation.swift
//  Heyphil
//
//  Created by Philcare on 12/12/2016.
//  Copyright © 2016 Philcare. All rights reserved.
//

import UIKit

class Conversation: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    @IBOutlet weak var txtMessage: UITextField!
    @IBOutlet var tableView: UITableView!
    var items: [String] = ["We", "Can", "Do"]
    var insertData = [InsertData]()
    var doctor = [Dictionary<String,Dictionary<String,AnyObject>>]()
    var content = Dictionary<String, AnyObject>()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        let imageName = "er_shield.jpg"
        let img = UIImage(named: imageName)
        var frame = CGRect(x: 50, y: 600, width: 50, height: 50)
        var newView = ObjectView(frame: frame)
        newView.image = img?.circleMask
        newView.isUserInteractionEnabled = true
        self.view.addSubview(newView)
        txtMessage.layer.borderWidth=2
        txtMessage.layer.cornerRadius=5
        txtMessage.layer.borderColor = UIColor(red: 0.00, green: 0.40, blue: 0.00, alpha: 1.0).cgColor;
        print(MemberInfo.Firstname+" "+MemberInfo.Lastname)
        tableView.dataSource = self
        tableView.delegate = self
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        if insertData.count > 0 {
            return
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {
        tableView.reloadData()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.insertData.count;
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        let imageName = "er_shield.jpg"
        let image = UIImage(named: imageName)
        cell.imageView?.image = image?.circleMask
        let data = insertData[indexPath.row]
        cell.textLabel?.text = data.text
        cell.textLabel?.contentMode = UIViewContentMode.scaleAspectFit
        cell.textLabel?.layer.cornerRadius = 5
        cell.textLabel?.layer.borderWidth = 2
        cell.textLabel?.layer.borderColor = UIColor(red: 0.00, green: 0.40, blue: 0.00, alpha: 1.0).cgColor;
        
        /**let imageName = "er_shield.jpg"
        let image = UIImage(named: imageName)
        let newImage = resizeImage(image: image!, toTheSize: CGSize(width: 70.0, height: 70.0))
        let cellImageLayer: CALayer?  = cell.imageView?.layer
        cellImageLayer!.cornerRadius = cellImageLayer!.frame.size.width / 5
        cellImageLayer!.masksToBounds = true
        cellImageLayer?.borderWidth = 2
        cellImageLayer?.borderColor = UIColor(red: 0.00, green: 0.40, blue: 0.00, alpha: 1.0).cgColor;
        cell.imageView?.image = newImage**/
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("You click #\(indexPath.row)!");
    }
    
    @IBAction func btnSend(_ sender: UIButton) {
        insertData.append(InsertData(text: txtMessage.text!))
        tableView.reloadData()
        if (txtMessage.text!.contains("Member"))
        {
            performSegue(withIdentifier: "memberInfo", sender: self)
            
        }
        else if (txtMessage.text!.contains("doctor"))
        {
             performSegue(withIdentifier: "searchdoctor", sender: self)
        }
        else if (txtMessage.text!.contains("provider"))
        {
            let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
            let vc: UIViewController = storyBoard.instantiateViewController(withIdentifier: "searchprovider")
            
            OperationQueue.main.addOperation {
                self.present(vc, animated: true, completion: nil)
            }
        }
    }
    func resizeImage(_ image:UIImage, toTheSize size:CGSize)->UIImage{
        
        
        let scale = CGFloat(max(size.width/image.size.width,
                                size.height/image.size.height))
        let width:CGFloat  = image.size.width * scale
        let height:CGFloat = image.size.height * scale;
        
        let rr:CGRect = CGRect(x: 0, y: 0, width: width, height: height)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        image.draw(in: rr)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return newImage!
    }
    }

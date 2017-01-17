//
//  SearchDoctor.swift
//  Heyphil
//
//  Created by Philcare on 15/01/2017.
//  Copyright © 2017 Philcare. All rights reserved.
//

import UIKit

class _SearchDoctor: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var BillingAddress: [String] = []
    var DoctorCode: [String] = []
    var DoctorName: [String] = []
    var DoctorLon: [String] = []
    var DoctorLat: [String] = []
     var items: [String] = ["We", "Can", "Do"]
    @IBOutlet weak var tblDoctor: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let url=URL(string:"https://apps.philcare.com.ph/PhilcareWatsonTest/Search.svc/SearchDoctors/?CertNo=5443460&Province=&Area=Makati%20city&DoctorName=&Specialization=")
        do {
            let allContactsData = try? Data(contentsOf: url!)
            let allContacts = try JSONSerialization.jsonObject(with: allContactsData!, options: JSONSerialization.ReadingOptions.allowFragments)
                as! [String : AnyObject]
            if let arrJSON = allContacts["SearchDoctorsResult"] as? NSArray{
                for index in 0...arrJSON.count-1 {
                    let aObject = arrJSON[index] as! [String : AnyObject]
                    BillingAddress.append(aObject["BillingAddress"] as! String)
                    DoctorCode.append(aObject["DoctorCode"] as! String)
                }
            }
            print(BillingAddress)
            print(DoctorCode)
        }
        catch
        {
        }
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        tblDoctor.reloadData()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell:UITableViewCell = self.tblDoctor.dequeueReusableCell(withIdentifier: "cell")! as UITableViewCell
        cell.textLabel?.text = items[indexPath.row]
        return cell
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

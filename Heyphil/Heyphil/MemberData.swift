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
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.isOpaque = true
        self.view.backgroundColor = UIColor.clear
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

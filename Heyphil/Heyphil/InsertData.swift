//
//  InsertData.swift
//  Heyphil
//
//  Created by Philcare on 19/12/2016.
//  Copyright © 2016 Philcare. All rights reserved.
//

import UIKit

class InsertData: NSObject {
    var text: String
    var completed: Bool
    
    init(text: String){
        self.text = text
        self.completed = false
    }
}

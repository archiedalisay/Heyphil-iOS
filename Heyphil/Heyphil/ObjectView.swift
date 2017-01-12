//
//  ObjectView.swift
//  Heyphil
//
//  Created by Philcare on 03/01/2017.
//  Copyright © 2017 Philcare. All rights reserved.
//

import UIKit

class ObjectView: UIImageView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("touched began")
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        var touch : UITouch! = touches.first! as UITouch
        self.center = touch.location(in: self.superview)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    }

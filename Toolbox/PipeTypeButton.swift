//
//  PipeTypeButton.swift
//  Toolbox
//
//  Created by Richard Seaman on 19/07/2015.
//  Copyright (c) 2015 RichApps. All rights reserved.
//

import UIKit

class PipeTypeButton: UIButton {

    let combinationStrings:[String] = ["Cold","Cold & Hot","Cold & Hot & Main","Rain","Hot","Main"]
    let images:[UIImage] = [UIImage(named: "C")!,UIImage(named: "CH")!,UIImage(named: "CHM")!,UIImage(named: "R")!,UIImage(named: "H")!,UIImage(named: "M")!]
    
    var row:Int = Int()
    
    var combination:Int = Int() {
        
        // Automatically change the image when the combination is changed
        didSet {
            if (self.combination < self.images.count) {
                self.setImage(self.images[self.combination], for: UIControlState())
            }
        }
        
    }

}

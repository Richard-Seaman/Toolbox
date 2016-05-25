//
//  ActionView.swift
//  Toolbox
//
//  Created by Richard Seaman on 06/12/2015.
//  Copyright © 2015 RichApps. All rights reserved.
//

import UIKit

class ActionView: UIView {

    var button:UIButton = UIButton()
    var label:UILabel = UILabel()
    
    // Change the dimensions of the actionview here
    // Note that the button height equals the width below 
    // The width is applied to both the button and label
    let width:CGFloat = 125
    var height:CGFloat = CGFloat()
    let labelHeight:CGFloat = 60
    
    override init(frame: CGRect) {
        
        // This is called if the view is used programmatically
        
        super.init(frame: frame)
        
        // Load the size to memory
        // The button and label width will be the same.
        // The button width and height will be the same
        self.height = self.width + self.labelHeight
        
        // Apply the defaults
        self.setDefaults()
        
        // add the objects to the view
        self.addSubview(button)
        self.addSubview(label)
        
        
        // add a background colour for testing
        // self.backgroundColor = UIColor.blueColor()
    }

    required init?(coder aDecoder: NSCoder) {
        
        // This is called if the view is used on the storyboard
        // The fatal error will cause a crash
        print("ActionView created from storyboard - crashed...")
        
        fatalError("init(coder:) has not been implemented")
    }
    
    func setDefaults() {
        
        // label defaults
        self.label.numberOfLines = 2
        self.label.minimumScaleFactor = 0.5
        self.label.text = "Action Title"
        self.label.textAlignment = NSTextAlignment.Center
        self.label.font = UIFont(name: self.label.font.fontName, size: 17)
        
        // button defaults
        self.button.setTitle("", forState: UIControlState.Normal)        
        self.button.layer.cornerRadius = 8
        self.button.layer.borderWidth = 1.5
        self.button.layer.borderColor = UIColor.blackColor().CGColor
        self.button.layer.backgroundColor = UIColor.whiteColor().CGColor
        self.button.clipsToBounds = true
        //self.button.setImage(UIImage(named: "InfoButton"), forState: UIControlState.Normal)
        
    }
    

}
